From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 4/4] net: phy: bcm7xxx: Make MII_BCM7XX_64CLK_MDIO naming consistent
Date: Wed,  3 Feb 2016 13:13:49 -0800
Message-ID: <1454534029-585-5-git-send-email-f.fainelli@gmail.com>
References: <1454534029-585-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, opendmb@gmail.com,
	jaedon.shin@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34194 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964797AbcBCVPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 16:15:55 -0500
Received: by mail-pa0-f47.google.com with SMTP id uo6so19872697pac.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 13:15:54 -0800 (PST)
In-Reply-To: <1454534029-585-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver is BCM7xxx, we were missing an additional X in the constant naming,
fix that to be consistent.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 568768abe3ed..0666f54ceeb5 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -24,7 +24,7 @@
 #define MII_BCM7XXX_100TX_FALSE_CAR	0x13
 #define MII_BCM7XXX_100TX_DISC		0x14
 #define MII_BCM7XXX_AUX_MODE		0x1d
-#define  MII_BCM7XX_64CLK_MDIO		BIT(12)
+#define  MII_BCM7XXX_64CLK_MDIO		BIT(12)
 #define MII_BCM7XXX_TEST		0x1f
 #define  MII_BCM7XXX_SHD_MODE_2		BIT(2)
 
@@ -247,7 +247,7 @@ static int bcm7xxx_config_init(struct phy_device *phydev)
 	int ret;
 
 	/* Enable 64 clock MDIO */
-	phy_write(phydev, MII_BCM7XXX_AUX_MODE, MII_BCM7XX_64CLK_MDIO);
+	phy_write(phydev, MII_BCM7XXX_AUX_MODE, MII_BCM7XXX_64CLK_MDIO);
 	phy_read(phydev, MII_BCM7XXX_AUX_MODE);
 
 	/* set shadow mode 2 */
-- 
2.1.0
