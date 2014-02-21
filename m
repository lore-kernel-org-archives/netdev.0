From: <cristian.bercaru@freescale.com>
Subject: [PATCH] net: phy: realtek: advertise PAUSE frame capabilities on Realtek PHY drivers
Date: Fri, 21 Feb 2014 18:20:02 +0200
Message-ID: <1392999602-29873-1-git-send-email-cristian.bercaru@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cristian Bercaru <cristian.bercaru@freescale.com>,
	<madalin.bucur@freescale.com>, <shaohui.xie@freescale.com>,
	<shruti@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe004.messaging.microsoft.com ([216.32.180.14]:23634
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755810AbaBUQUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 11:20:17 -0500
Received: from mail128-va3 (localhost [127.0.0.1])	by
 mail128-va3-R.bigfish.com (Postfix) with ESMTP id 043224C0244	for
 <netdev@vger.kernel.org>; Fri, 21 Feb 2014 16:20:16 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cristian Bercaru <cristian.bercaru@freescale.com>

Enable the advertisment of symmetric and asymmetric PAUSE frame
capabilities on all Realtek PHY drivers.

Signed-off-by: Cristian Bercaru <cristian.bercaru@freescale.com>
---
 drivers/net/phy/realtek.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index fa1d69a..8c59960 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -69,7 +69,8 @@ static struct phy_driver rtl8201cp_driver = {
 	.phy_id         = 0x00008201,
 	.name           = "RTL8201CP Ethernet",
 	.phy_id_mask    = 0x0000ffff,
-	.features       = PHY_BASIC_FEATURES,
+	.features       = PHY_BASIC_FEATURES |
+			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags          = PHY_HAS_INTERRUPT,
 	.config_aneg    = &genphy_config_aneg,
 	.read_status    = &genphy_read_status,
@@ -81,7 +82,8 @@ static struct phy_driver rtl8211b_driver = {
 	.phy_id		= 0x001cc912,
 	.name		= "RTL8211B Gigabit Ethernet",
 	.phy_id_mask	= 0x001fffff,
-	.features	= PHY_GBIT_FEATURES,
+	.features	= PHY_GBIT_FEATURES |
+			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= &genphy_config_aneg,
 	.read_status	= &genphy_read_status,
@@ -95,7 +97,8 @@ static struct phy_driver rtl8211e_driver = {
 	.phy_id		= 0x001cc915,
 	.name		= "RTL8211E Gigabit Ethernet",
 	.phy_id_mask	= 0x001fffff,
-	.features	= PHY_GBIT_FEATURES,
+	.features	= PHY_GBIT_FEATURES |
+			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= &genphy_config_aneg,
 	.read_status	= &genphy_read_status,
-- 
1.7.11.7
