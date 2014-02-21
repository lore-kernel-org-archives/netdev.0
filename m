From: <cristian.bercaru@freescale.com>
Subject: [PATCH] net: phy: vitesse: advertise PAUSE frame capabilities on Vitesse PHY drivers
Date: Fri, 21 Feb 2014 18:19:44 +0200
Message-ID: <1392999584-29836-1-git-send-email-cristian.bercaru@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cristian Bercaru <cristian.bercaru@freescale.com>,
	<madalin.bucur@freescale.com>, <shaohui.xie@freescale.com>,
	<shruti@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:23317
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755810AbaBUQT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 11:19:59 -0500
Received: from mail20-va3 (localhost [127.0.0.1])	by mail20-va3-R.bigfish.com
 (Postfix) with ESMTP id D5D292201F1	for <netdev@vger.kernel.org>; Fri, 21 Feb
 2014 16:19:58 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cristian Bercaru <cristian.bercaru@freescale.com>

Enable the advertisment of symmetric and asymmetric PAUSE frame
capabilities on all Vitesse PHY drivers.

Signed-off-by: Cristian Bercaru <cristian.bercaru@freescale.com>
---
 drivers/net/phy/vitesse.c | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 14372c6..3124b31 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -227,7 +227,8 @@ static struct phy_driver vsc82xx_driver[] = {
 	.phy_id         = PHY_ID_VSC8234,
 	.name           = "Vitesse VSC8234",
 	.phy_id_mask    = 0x000ffff0,
-	.features       = PHY_GBIT_FEATURES,
+	.features       = PHY_GBIT_FEATURES |
+			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags          = PHY_HAS_INTERRUPT,
 	.config_init    = &vsc824x_config_init,
 	.config_aneg    = &vsc82x4_config_aneg,
@@ -239,7 +240,8 @@ static struct phy_driver vsc82xx_driver[] = {
 	.phy_id		= PHY_ID_VSC8244,
 	.name		= "Vitesse VSC8244",
 	.phy_id_mask	= 0x000fffc0,
-	.features	= PHY_GBIT_FEATURES,
+	.features       = PHY_GBIT_FEATURES |
+			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &vsc824x_config_init,
 	.config_aneg	= &vsc82x4_config_aneg,
@@ -251,7 +253,8 @@ static struct phy_driver vsc82xx_driver[] = {
 	.phy_id		= PHY_ID_VSC8514,
 	.name		= "Vitesse VSC8514",
 	.phy_id_mask	= 0x000ffff0,
-	.features	= PHY_GBIT_FEATURES,
+	.features       = PHY_GBIT_FEATURES |
+			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &vsc824x_config_init,
 	.config_aneg	= &vsc82x4_config_aneg,
@@ -263,7 +266,8 @@ static struct phy_driver vsc82xx_driver[] = {
 	.phy_id         = PHY_ID_VSC8574,
 	.name           = "Vitesse VSC8574",
 	.phy_id_mask    = 0x000ffff0,
-	.features       = PHY_GBIT_FEATURES,
+	.features       = PHY_GBIT_FEATURES |
+			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags          = PHY_HAS_INTERRUPT,
 	.config_init    = &vsc824x_config_init,
 	.config_aneg    = &vsc82x4_config_aneg,
@@ -275,7 +279,8 @@ static struct phy_driver vsc82xx_driver[] = {
 	.phy_id         = PHY_ID_VSC8662,
 	.name           = "Vitesse VSC8662",
 	.phy_id_mask    = 0x000ffff0,
-	.features       = PHY_GBIT_FEATURES,
+	.features       = PHY_GBIT_FEATURES |
+			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags          = PHY_HAS_INTERRUPT,
 	.config_init    = &vsc824x_config_init,
 	.config_aneg    = &vsc82x4_config_aneg,
@@ -288,7 +293,8 @@ static struct phy_driver vsc82xx_driver[] = {
 	.phy_id		= PHY_ID_VSC8221,
 	.phy_id_mask	= 0x000ffff0,
 	.name		= "Vitesse VSC8221",
-	.features	= PHY_GBIT_FEATURES,
+	.features       = PHY_GBIT_FEATURES |
+			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &vsc8221_config_init,
 	.config_aneg	= &genphy_config_aneg,
@@ -301,7 +307,8 @@ static struct phy_driver vsc82xx_driver[] = {
 	.phy_id		= PHY_ID_VSC8211,
 	.phy_id_mask	= 0x000ffff0,
 	.name		= "Vitesse VSC8211",
-	.features	= PHY_GBIT_FEATURES,
+	.features       = PHY_GBIT_FEATURES |
+			SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &vsc8221_config_init,
 	.config_aneg	= &genphy_config_aneg,
-- 
1.7.11.7
