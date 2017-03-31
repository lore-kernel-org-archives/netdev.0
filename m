From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 0/2] rds: tcp: couple of minor bug fixes
Date: Fri, 31 Mar 2017 15:56:29 -0700
Message-ID: <cover.1490814967.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, santosh.shilimkar@oracle.com,
        sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26591 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751855AbdDASSm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 14:18:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of minor bugfixes that showed up during testing

Sowmini Varadhan (2):
  rds: tcp: allow progress of rds_conn_shutdown if the rds_connection
    is marked ERROR by an intervening FIN
  rds: tcp: canonical connection order for all paths with index > 0

 net/rds/connection.c |   10 +++++++++-
 net/rds/threads.c    |    2 +-
 2 files changed, 10 insertions(+), 2 deletions(-)
