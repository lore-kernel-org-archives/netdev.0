From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [RFC/PATCH 2.6.20-rc6 4/4] spidernet: remove txram full logging
Date: Fri, 02 Feb 2007 19:33:11 +0900 (JST)
Message-ID: <200702021033.l12AXCdE021278@toshiba.co.jp>
References: <200702011204.30526.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jim@jklewis.com, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: jens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx12.toshiba.co.jp ([61.202.160.132]:41418 "EHLO
	imx12.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbXBBKeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Feb 2007 05:34:09 -0500
In-Reply-To: <200702011204.30526.jens@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patches removes logging for SPIDER_NET_GTMFLLINT interrupts.
Since the interrupts are not irregular, and they happen frequently
when using 100Mbps network switches.

This patch is just for a test. Please try this if you can.

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
---

--- org-linux-powerpc-git/drivers/net/spider_net.c	2007-02-02 14:35:14.000000000 +0900
+++ linux-powerpc-git/drivers/net/spider_net.c	2007-02-02 14:35:49.000000000 +0900
@@ -1435,8 +1435,8 @@
 				switch (i)
 	{
 	case SPIDER_NET_GTMFLLINT:
-		if (netif_msg_intr(card) && net_ratelimit())
-			pr_err("Spider TX RAM full\n");
+		/* TX RAM full may happen on a usual case.
+		 * Logging is not needed. */
 		show_error = 0;
 		break;
 	case SPIDER_NET_GRFDFLLINT: /* fallthrough */
