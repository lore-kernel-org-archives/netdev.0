From: Shruti Kanetkar <Shruti@Freescale.com>
Subject: [PATCH] net/fsl: xgmac_mdio is dependent on OF_MDIO
Date: Wed, 11 Jun 2014 13:48:17 -0500
Message-ID: <1402512497-16963-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Andy Fleming <afleming@gmail.com>,
	"Shruti Kanetkar" <Shruti@Freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0141.outbound.protection.outlook.com ([207.46.163.141]:53298
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753694AbaFKSsX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 14:48:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@gmail.com>

Signed-off-by: Shruti Kanetkar <Shruti@Freescale.com>
---
 drivers/net/ethernet/freescale/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index 6048dc8..2703083 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -67,6 +67,7 @@ config FSL_XGMAC_MDIO
 	tristate "Freescale XGMAC MDIO"
 	depends on FSL_SOC
 	select PHYLIB
+	select OF_MDIO
 	---help---
 	  This driver supports the MDIO bus on the Fman 10G Ethernet MACs.
 
-- 
1.8.3.1
