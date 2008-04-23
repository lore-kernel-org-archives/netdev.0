From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 4/5] mv643xx_eth: shorten shared platform driver name
Date: Thu, 24 Apr 2008 01:27:44 +0200
Message-ID: <20080423232744.GF17159@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@cam.org>
To: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:60280 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158AbYDWX1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 19:27:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the MV643XX_ETH_SHARED_NAME platform driver name to something
shorter than 19 characters, so that we can register multiple (otherwise
we end up with sysfs conflicts since all instances will map to
"mv643xx_eth_shared." as there is a 20-char sysfs file name limit.)

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Acked-by: Nicolas Pitre <nico@marvell.com>

Index: linux-2.6.25-git4/include/linux/mv643xx_eth.h
===================================================================
--- linux-2.6.25-git4.orig/include/linux/mv643xx_eth.h
+++ linux-2.6.25-git4/include/linux/mv643xx_eth.h
@@ -7,8 +7,8 @@
 
 #include <linux/mbus.h>
 
-#define MV643XX_ETH_SHARED_NAME		"mv643xx_eth_shared"
-#define MV643XX_ETH_NAME		"mv643xx_eth"
+#define MV643XX_ETH_SHARED_NAME		"mv643xx_eth"
+#define MV643XX_ETH_NAME		"mv643xx_eth_port"
 #define MV643XX_ETH_SHARED_REGS		0x2000
 #define MV643XX_ETH_SHARED_REGS_SIZE	0x2000
 #define MV643XX_ETH_BAR_4		0x2220
