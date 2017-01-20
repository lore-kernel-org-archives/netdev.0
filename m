From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 6/7] net: phy: bcm7xxx: Add entry for BCM7278
Date: Fri, 20 Jan 2017 12:36:33 -0800
Message-ID: <20170120203634.2773-7-f.fainelli@gmail.com>
References: <20170120203634.2773-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36483 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753663AbdATUgt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 15:36:49 -0500
Received: by mail-pg0-f68.google.com with SMTP id 75so7650626pgf.3
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 12:36:49 -0800 (PST)
In-Reply-To: <20170120203634.2773-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the BCM7278 28nm process Gigabit Ethernet PHY.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 2 ++
 include/linux/brcmphy.h   | 1 +
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 264b085d796b..fb11927de0ff 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -416,6 +416,7 @@ static int bcm7xxx_28nm_probe(struct phy_device *phydev)
 
 static struct phy_driver bcm7xxx_driver[] = {
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7250, "Broadcom BCM7250"),
+	BCM7XXX_28NM_GPHY(PHY_ID_BCM7278, "Broadcom BCM7278"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7364, "Broadcom BCM7364"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7366, "Broadcom BCM7366"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7439, "Broadcom BCM7439"),
@@ -430,6 +431,7 @@ static struct phy_driver bcm7xxx_driver[] = {
 
 static struct mdio_device_id __maybe_unused bcm7xxx_tbl[] = {
 	{ PHY_ID_BCM7250, 0xfffffff0, },
+	{ PHY_ID_BCM7278, 0xfffffff0, },
 	{ PHY_ID_BCM7364, 0xfffffff0, },
 	{ PHY_ID_BCM7366, 0xfffffff0, },
 	{ PHY_ID_BCM7346, 0xfffffff0, },
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 4f7d8be9ddbf..295fb3e73de5 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -24,6 +24,7 @@
 #define PHY_ID_BCM57780			0x03625d90
 
 #define PHY_ID_BCM7250			0xae025280
+#define PHY_ID_BCM7278			0xae0251a0
 #define PHY_ID_BCM7364			0xae025260
 #define PHY_ID_BCM7366			0x600d8490
 #define PHY_ID_BCM7346			0x600d8650
-- 
2.9.3
