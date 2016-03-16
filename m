From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next v4 0/2] RDS: TCP: tunable socket buffer parameters
Date: Wed, 16 Mar 2016 11:38:11 -0700
Message-ID: <cover.1458152608.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
	santosh.shilimkar@oracle.com, hannes@stressinduktion.org,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30712 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934328AbcCPSik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 14:38:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1 uses sysctl to create tunable socket buffer size parameters.

Patch 2 removes an unuused constant.

v2: use sysctl
v3: review comments from Santosh Shilimkar, Eric Dumazet
v4: review comments from Hannes Sowa

Sowmini Varadhan (2):
  RDS: TCP: Add sysctl tunables for sndbuf/rcvbuf on rds-tcp socket
  RDS: TCP: Remove unused constant

 net/rds/tcp.c |  145 ++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 134 insertions(+), 11 deletions(-)
