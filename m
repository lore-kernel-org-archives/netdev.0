From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH 4/6] sctp: Add sysctl support for Auto-ASCONF.
Date: Thu, 28 Apr 2011 10:08:07 +0900
Message-ID: <FFFA135B-CE04-4D02-BAEC-00EDD6F8FE7E@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Honda Michio <micchie@sfc.wide.ad.jp>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:38735 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757409Ab1D1BII convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 21:08:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From cceaf42321b86893e1da559fc629014b97b275b9 Mon Sep 17 00:00:00 2001
From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Tue, 26 Apr 2011 17:36:05 +0900
Subject: [PATCH 4/6] sctp: Add sysctl support for Auto-ASCONF.

This patch allows the system administrator to change default Auto-ASCONF on/off behavior via an sysctl value.

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/sctp/sysctl.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 50cb57f..6b39529 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -183,6 +183,13 @@ static ctl_table sctp_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "default_auto_asconf",
+		.data		= &sctp_default_auto_asconf,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "prsctp_enable",
 		.data		= &sctp_prsctp_enable,
 		.maxlen		= sizeof(int),
-- 
1.7.3.2


