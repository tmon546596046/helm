#!/usr/bin/env bash

# Copyright The Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -euo pipefail

VERSION=
if [[ -n "${CIRCLE_TAG:-}" ]]; then
  VERSION="${CIRCLE_TAG}"
elif [[ "${CIRCLE_BRANCH:-}" == "master" ]]; then
  VERSION="canary"
else
  VERSION="canary"
fi

echo "Install docker client"
VER="17.09.0-ce"
curl -L -o /tmp/docker-$VER.tgz https://download.docker.com/linux/static/stable/x86_64/docker-$VER.tgz
tar -xz -C /tmp -f /tmp/docker-$VER.tgz
mv /tmp/docker/* /usr/bin

docker login -u ${DOCKERHUB_USERNAME:-} -p ${DOCKERHUB_PASSWORD:-} docker.io/${DOCKERHUB_USERNAME:-}

echo "Building the tiller image"
make docker-build VERSION="${VERSION}"

echo "Pushing image to dockerhub"
docker push "piranhahu/tiller:${VERSION}"

echo "Building helm binaries"
make build-cross
make dist checksum VERSION="${VERSION}"

echo "Pushing image to dockerhub"
make docker-all VERSION="${VERSION}"
docker push "piranhahu/helm:${VERSION}"
