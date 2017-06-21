From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 0/2] rds: tcp: fixes
Date: Wed, 21 Jun 2017 13:40:11 -0700
Message-ID: <cover.1498074496.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
        santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49065 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751865AbdFUUmp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 16:42:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch1 is a bug fix for correct reconnect when a connection
is restarted. Patch 2 accelerates cleanup by setting linger
to 1 and sending a RST to the peer.

Sowmini Varadhan (2):
  rds: tcp: send handshake ping-probe from passive endpoint
  rds: tcp: set linger to 1 when unloading a rds-tcp

 net/rds/connection.c  |    1 +
 net/rds/rds.h         |    4 +++-
 net/rds/recv.c        |    6 +++---
 net/rds/send.c        |   14 ++++++--------
 net/rds/tcp.h         |    1 +
 net/rds/tcp_connect.c |    2 ++
 net/rds/tcp_listen.c  |    4 +++-
 7 files changed, 19 insertions(+), 13 deletions(-)
