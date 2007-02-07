From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH 4/4] spidernet: remove txram full logging
Date: Wed, 07 Feb 2007 17:57:28 +0900 (JST)
Message-ID: <200702070857.l178vhav020612@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, jim@jklewis.com
To: jgarzik@pobox.com, jens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx12.toshiba.co.jp ([61.202.160.132]:41233 "EHLO
	imx12.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161044AbXBGI6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 03:58:07 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patches removes logging for SPIDER_NET_GTMFLLINT interrupts.
Since the interrupts are not irregular, and they happen frequently
when using 100Mbps network switches.

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
---

--- org-linux-powerpc-git/drivers/net/spider_net.c	2007-02-06 20:44:47.000000000 +0900
+++ linux-powerpc-git/drivers/net/spider_net.c	2007-02-06 20:48:38.000000000 +0900
@@ -1417,8 +1417,8 @@
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
