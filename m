From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 0/2] RDS: TCP: bug fixes
Date: Fri,  4 Nov 2016 10:04:10 -0700
Message-ID: <cover.1478276221.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
        sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31926 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932899AbcKDREW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 13:04:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of bug fixes identified during testing. 

Sowmini Varadhan (2):
  RDS: TCP: report addr/port info based on TCP socket in rds-info
  RDS: TCP: start multipath acceptor loop at 0

 net/rds/tcp.c        |   20 +++++++++++++-------
 net/rds/tcp_listen.c |    2 +-
 2 files changed, 14 insertions(+), 8 deletions(-)
