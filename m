From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 5/5][MV643XX_ETH] shorten shared platform driver name
Date: Mon, 17 Mar 2008 21:06:27 +0100
Message-ID: <20080317200627.GF18726@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Saeed Bishara <saeed@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:47088 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758885AbYCQUG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 16:06:29 -0400
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
