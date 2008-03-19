From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 4/4] mv643xx_eth: shorten shared platform driver name
Date: Wed, 19 Mar 2008 08:50:39 +0100
Message-ID: <20080319075039.GE5010@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:47616 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765828AbYCSUR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 16:17:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the MV643XX_ETH_SHARED_NAME platform driver name to something
shorter than 19 characters, so that we can register multiple (otherwise
we end up with sysfs conflicts since all instances will map to
"mv643xx_eth_shared." as there is a 20-char sysfs file name limit.)

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.25-rc6/include/linux/mv643xx_eth.h
===================================================================
--- linux-2.6.25-rc6.orig/include/linux/mv643xx_eth.h
+++ linux-2.6.25-rc6/include/linux/mv643xx_eth.h
@@ -7,8 +7,8 @@
 
 #include <linux/mbus.h>
 
-#define MV643XX_ETH_SHARED_NAME		"mv643xx_eth_shared"
-#define MV643XX_ETH_NAME		"mv643xx_eth"
+#define MV643XX_ETH_SHARED_NAME		"mv643xx_eth"
+#define MV643XX_ETH_NAME		"mv643xx_eth_port"
 #define MV643XX_ETH_SHARED_REGS		0x2000
 #define MV643XX_ETH_SHARED_REGS_SIZE	0x2000
 #define MV643XX_ETH_BAR_4		0x2220


----
