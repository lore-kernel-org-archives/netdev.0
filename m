From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH net-next-2.6 v4 2/5] sctp: Add sysctl support for Auto-ASCONF
Date: Thu, 21 Apr 2011 04:24:29 +0900
Message-ID: <E594004B-8A1A-4F87-BE11-C84315CE6277@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:52334 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754541Ab1DTTY3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 15:24:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows the system administrator to change default Auto-ASCONF on/off behavior via an sysctl value.  

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
---
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 50cb57f..df39789 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -183,6 +183,13 @@ static ctl_table sctp_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
+		.procname	= "auto_asconf_enable",
+		.data		= &sctp_auto_asconf_enable,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "prsctp_enable",
 		.data		= &sctp_prsctp_enable,
 		.maxlen		= sizeof(int),

