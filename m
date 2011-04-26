From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH net-next-2.6 v6 2/5] sctp: Add sysctl support for Auto-ASCONF
Date: Tue, 26 Apr 2011 13:29:43 +0900
Message-ID: <4B304B0D-35AC-4372-84F3-EFBC5A4C7BF2@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:36210 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751332Ab1DZE3o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 00:29:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows the system administrator to change default Auto-ASCONF on/off behavior via an sysctl value.  

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
---
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

