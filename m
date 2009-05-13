From: Emil Medve <Emilian.Medve@Freescale.com>
Subject: [PATCH] mv643xx_eth: Remove a stale PPC_MULTIPLATFORM
Date: Wed, 13 May 2009 11:04:58 -0500
Message-ID: <1242230698-15684-1-git-send-email-Emilian.Medve@Freescale.com>
Cc: netdev@vger.kernel.org, Emil Medve <Emilian.Medve@Freescale.com>
To: buytenh@marvell.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:57344 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756717AbZEMQFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 12:05:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PPC_MULTIPLATFORM was killed in commit 28794d3 but this stale occurrence was
hiding the mv643xx_eth driver in some cases (e.g. Pegasos II)

Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
---
 drivers/net/Kconfig |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 214a92d..c3eb471 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1,4 +1,3 @@
-
 #
 # Network device configuration
 #
@@ -2351,7 +2350,7 @@ config UGETH_TX_ON_DEMAND
 
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
-	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32) || PLAT_ORION
+	depends on MV64360 || MV64X60 || PPC32 || PLAT_ORION
 	select INET_LRO
 	select PHYLIB
 	help
-- 
1.6.3

