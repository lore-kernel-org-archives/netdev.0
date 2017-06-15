From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 0/3] rds: tcp: misc bug fixes
Date: Thu, 15 Jun 2017 11:28:52 -0700
Message-ID: <cover.1497547381.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
        santosh.shilimkar@oracle.com, imanti.mendez@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45488 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752469AbdFOSb3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 14:31:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains 2 bug fixes (patch2, patch3) and one bit of 
code cleanup (patch1) identified during database testing

Sowmini Varadhan (3):
  rds: tcp: remove cp_outgoing
  rds: tcp: various endian-ness fixes
  rds: tcp: Set linger when rejecting an incoming conn in
    rds_tcp_accept_one

 net/rds/connection.c  |    5 -----
 net/rds/rds.h         |    4 ++--
 net/rds/recv.c        |   12 +++++++-----
 net/rds/send.c        |   11 +++++++----
 net/rds/tcp_connect.c |    3 +--
 net/rds/tcp_listen.c  |   40 +++++++++++++++++++++++-----------------
 net/rds/threads.c     |    5 +++--
 7 files changed, 43 insertions(+), 37 deletions(-)
