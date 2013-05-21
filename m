From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 2/2 net-next v2] phy: bcm63xx: report Broadcom BCM63xx
 PHYs as internal
Date: Tue, 21 May 2013 12:09:48 +0100
Message-ID: <1369134588-18339-3-git-send-email-f.fainelli@gmail.com>
References: <1369134588-18339-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com, jogo@openwrt.org,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3471 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751832Ab3EULKC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 07:10:02 -0400
In-Reply-To: <1369134588-18339-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Broadcom BCM63xx PHY driver is for the SoC internal PHYs, flag these
as internal PHY devices.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
No changes since v1

 drivers/net/phy/bcm63xx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/bcm63xx.c b/drivers/net/phy/bcm63xx.c
index 84c7a39..ac55b08 100644
--- a/drivers/net/phy/bcm63xx.c
+++ b/drivers/net/phy/bcm63xx.c
@@ -78,7 +78,7 @@ static struct phy_driver bcm63xx_driver[] = {
 	.name		= "Broadcom BCM63XX (1)",
 	/* ASYM_PAUSE bit is marked RO in datasheet, so don't cheat */
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
-	.flags		= PHY_HAS_INTERRUPT,
+	.flags		= PHY_HAS_INTERRUPT | PHY_IS_INTERNAL,
 	.config_init	= bcm63xx_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
@@ -91,7 +91,7 @@ static struct phy_driver bcm63xx_driver[] = {
 	.phy_id_mask	= 0xfffffc00,
 	.name		= "Broadcom BCM63XX (2)",
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
-	.flags		= PHY_HAS_INTERRUPT,
+	.flags		= PHY_HAS_INTERRUPT | PHY_IS_INTERNAL,
 	.config_init	= bcm63xx_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
-- 
1.8.1.2
