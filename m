From: <shh.xie@gmail.com>
Subject: [PATCH] net/fsl: remove dependency FSL_SOC from MDIO
Date: Tue, 10 Mar 2015 18:31:12 +0800
Message-ID: <1425983472-24629-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0066.outbound.protection.outlook.com ([157.56.111.66]:60112
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753219AbbCJLgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 07:36:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

FSL_PQ_MDIO and FSL_XGMAC_MDIO are not really depend on FSL_SOC, they
can build on non-PPC platforms.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/ethernet/freescale/Kconfig | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index ba84c4a..25e3425 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -58,14 +58,12 @@ source "drivers/net/ethernet/freescale/fs_enet/Kconfig"
 
 config FSL_PQ_MDIO
 	tristate "Freescale PQ MDIO"
-	depends on FSL_SOC
 	select PHYLIB
 	---help---
 	  This driver supports the MDIO bus used by the gianfar and UCC drivers.
 
 config FSL_XGMAC_MDIO
 	tristate "Freescale XGMAC MDIO"
-	depends on FSL_SOC
 	select PHYLIB
 	select OF_MDIO
 	---help---
-- 
1.8.4.1
