FROM ubuntu:jammy AS erlj
RUN apt-get update && apt-get install erlang -y --no-install-recommends


FROM erlj AS base
RUN set -eux; \
  apt-get install -y gosu make git curl; \
  rm -rf /var/lib/apt/lists/*; \
  gosu nobody true
COPY buildentry.sh /usr/local/bin/entrypoint.sh
RUN chmod 555 /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]


FROM base as build
RUN mkdir /usr/local/src/doctorworm
WORKDIR /usr/local/src/doctorworm
COPY . /usr/local/src/doctorworm
RUN make

FROM ubuntu:jammy
WORKDIR /opt/
COPY --from=build /usr/local/src/doctorworm/_rel/doctorworm_release/doctorworm_release-1.tar.gz /opt/
RUN tar xf doctorworm_release-1.tar.gz
EXPOSE 22884
CMD ["bin/doctorworm_release", "foreground"]
