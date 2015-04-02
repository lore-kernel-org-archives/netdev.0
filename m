From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv2 0/6]  RDS: RDS core bug fixes
Date: Thu,  2 Apr 2015 10:19:34 -0400
Message-ID: <cover.1427983908.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, agrover@redhat.com, clm@fb.com,
	zab@zabbo.net, ajaykumar.hotchandani@oracle.com,
	sergei.shtylyov@cogentembedded.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30943 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704AbbDBOTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:19:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch-series updates the RDS core and rds-tcp modules with
some bug fixes that were originally authored by  Andy Grover,
Zach Brown, and Chris Mason. 

v2: code review comment from Sergei Shtylyov

Sowmini Varadhan (6):
  RDS: Re-add pf/sol access via sysctl
  RDS: only use passive connections when addresses match
  rds: check for excessive looping in rds_send_xmit
  RDS: make sure not to loop forever inside rds_send_xmit
  RDS: rds_send_xmit is called under a spinlock, lets not do a
    cond_resched()
  RDS: don't trust the LL_SEND_FULL bit

 net/rds/connection.c |    3 +-
 net/rds/rds.h        |    1 +
 net/rds/send.c       |   56 ++++++++++++++++++++++++++++++++++++++++++++-----
 net/rds/sysctl.c     |   20 +++++++++++++++++
 net/rds/threads.c    |    2 +
 5 files changed, 75 insertions(+), 7 deletions(-)
