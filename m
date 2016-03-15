From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next v3 0/2] RDS: TCP: tunable socket buffer parameters
Date: Tue, 15 Mar 2016 11:53:13 -0700
Message-ID: <cover.1458064902.git.sowmini.varadhan@oracle.com>
Cc: sowmini.varadhan@oracle.com, davem@davemloft.net,
	santosh.shilimkar@oracle.com, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50941 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932212AbcCOSxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 14:53:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1 uses sysctl to create tunable socket buffer size parameters.

Patch 2 removes an unuused constant.

Changes since v2: review comments from Santosh Shilimkar, Eric Dumazet

Sowmini Varadhan (2):
  RDS: TCP: Add sysctl tunables for sndbuf/rcvbuf on rds-tcp socket
  RDS: TCP: Remove unused constant

 net/rds/tcp.c |  143 +++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 133 insertions(+), 10 deletions(-)
