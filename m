From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH 2/5] spidernet: increase auto-negotiation timeout to 5
 seconds
Date: Fri, 11 Apr 2008 12:29:20 +0900 (JST)
Message-ID: <20080411.122920.-1350519843.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jens@de.ibm.com, netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:49468 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756704AbYDKDgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 23:36:13 -0400
Received: from imx2.toshiba.co.jp (imx2 [202.33.96.24])
	by imx9.toshiba.co.jp  with ESMTP id m3B3aBm7021033
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 12:36:12 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch extends the timeout for spidernet auto-negotiation.
Auto-negotiation often fails to finish in 2 seconds.

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
Acked-by: Jens Osterkamp <jens@de.ibm.com>
---

Index: linux-powerpc-git/drivers/net/spider_net.h
===================================================================
--- linux-powerpc-git.orig/drivers/net/spider_net.h
+++ linux-powerpc-git/drivers/net/spider_net.h
@@ -52,7 +52,7 @@ extern char spider_net_driver_name[];
 
 #define SPIDER_NET_TX_TIMER			(HZ/5)
 #define SPIDER_NET_ANEG_TIMER			(HZ)
-#define SPIDER_NET_ANEG_TIMEOUT			2
+#define SPIDER_NET_ANEG_TIMEOUT			5
 
 #define SPIDER_NET_RX_CSUM_DEFAULT		1
 
