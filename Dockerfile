FROM golang:1.10 AS BUILD

# doing dependency build separated from source build optimizes time for developer, but is not required
# install external dependencies first
# ADD go-plugins-helpers/Gopkg.toml $GOPATH/src/go-plugins-helpers/
WORKDIR $GOPATH/src/schelly-postgres

ADD /main.go $GOPATH/src/schelly-postgres/main.go
RUN go get -v schelly-postgres

# now build source code
ADD schelly-postgres $GOPATH/src/schelly-postgres
RUN go get -v schelly-postgres

FROM postgres:10

EXPOSE 7070

# ENV RESTIC_PASSWORD ''
ENV LISTEN_PORT 7070
ENV LISTEN_IP '0.0.0.0'
ENV LOG_LEVEL 'debug'

ENV TARGET_DATA_BACKEND 'file'

ENV SIMULTANEOUS_WRITES '3'
ENV MAX_BANDWIDTH_WRITE '0'
ENV SIMULTANEOUS_READS '10'
ENV MAX_BANDWIDTH_READ '0'

ENV PRE_POST_TIMEOUT '7200'
ENV PRE_BACKUP_COMMAND ''
ENV POST_BACKUP_COMMAND ''

COPY --from=BUILD /go/bin/* /bin/
ADD startup.sh /

CMD [ "/startup.sh" ]
