From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 12/15] broadcom: Add flow control support
Date: Mon, 3 Nov 2008 02:27:32 -0800
Message-ID: <1225751629.6199@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4895 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756649AbYKCWeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:34:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds flow control support to Broadcom phys.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/phy/broadcom.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 4b4dc98..0fe3749 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -335,7 +335,8 @@ static struct phy_driver bcm5411_driver = {
 	.phy_id		= 0x00206070,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5411",
-	.features	= PHY_GBIT_FEATURES,
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -349,7 +350,8 @@ static struct phy_driver bcm5421_driver = {
 	.phy_id		= 0x002060e0,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5421",
-	.features	= PHY_GBIT_FEATURES,
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -363,7 +365,8 @@ static struct phy_driver bcm5461_driver = {
 	.phy_id		= 0x002060c0,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5461",
-	.features	= PHY_GBIT_FEATURES,
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -377,7 +380,8 @@ static struct phy_driver bcm5464_driver = {
 	.phy_id		= 0x002060b0,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5464",
-	.features	= PHY_GBIT_FEATURES,
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -391,7 +395,8 @@ static struct phy_driver bcm5481_driver = {
 	.phy_id		= 0x0143bca0,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5481",
-	.features	= PHY_GBIT_FEATURES,
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
 	.config_aneg	= bcm5481_config_aneg,
@@ -405,7 +410,8 @@ static struct phy_driver bcm5482_driver = {
 	.phy_id		= 0x0143bcb0,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5482",
-	.features	= PHY_GBIT_FEATURES,
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm5482_config_init,
 	.config_aneg	= genphy_config_aneg,
-- 
1.5.6.4



