From: Jaedon Shin <jaedon.shin@gmail.com>
Subject: [PATCH] net: phy: bcm7xxx: Add entries for Broadcom BCM7346 and BCM7362
Date: Fri, 25 Mar 2016 12:46:54 +0900
Message-ID: <1458877614-94202-1-git-send-email-jaedon.shin@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35513 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797AbcCYDrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 23:47:08 -0400
Received: by mail-pf0-f195.google.com with SMTP id u190so10230515pfb.2
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 20:47:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add PHY entries for the Broadcom BCM7346 and BCM7362 chips, these are
40nm generation Ethernet PHY.

Fixes: 815717d1473e ("net: phy: bcm7xxx: Remove wildcard entries")
Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 4 ++++
 include/linux/brcmphy.h   | 2 ++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index b881a7b1e4f6..9636da0b6efc 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -339,6 +339,8 @@ static struct phy_driver bcm7xxx_driver[] = {
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7439, "Broadcom BCM7439"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7439_2, "Broadcom BCM7439 (2)"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7445, "Broadcom BCM7445"),
+	BCM7XXX_40NM_EPHY(PHY_ID_BCM7346, "Broadcom BCM7346"),
+	BCM7XXX_40NM_EPHY(PHY_ID_BCM7362, "Broadcom BCM7362"),
 	BCM7XXX_40NM_EPHY(PHY_ID_BCM7425, "Broadcom BCM7425"),
 	BCM7XXX_40NM_EPHY(PHY_ID_BCM7429, "Broadcom BCM7429"),
 	BCM7XXX_40NM_EPHY(PHY_ID_BCM7435, "Broadcom BCM7435"),
@@ -348,6 +350,8 @@ static struct mdio_device_id __maybe_unused bcm7xxx_tbl[] = {
 	{ PHY_ID_BCM7250, 0xfffffff0, },
 	{ PHY_ID_BCM7364, 0xfffffff0, },
 	{ PHY_ID_BCM7366, 0xfffffff0, },
+	{ PHY_ID_BCM7346, 0xfffffff0, },
+	{ PHY_ID_BCM7362, 0xfffffff0, },
 	{ PHY_ID_BCM7425, 0xfffffff0, },
 	{ PHY_ID_BCM7429, 0xfffffff0, },
 	{ PHY_ID_BCM7439, 0xfffffff0, },
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index f0ba9c2ec639..e3354b74286c 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -24,6 +24,8 @@
 #define PHY_ID_BCM7250			0xae025280
 #define PHY_ID_BCM7364			0xae025260
 #define PHY_ID_BCM7366			0x600d8490
+#define PHY_ID_BCM7346			0x600d8650
+#define PHY_ID_BCM7362			0x600d84b0
 #define PHY_ID_BCM7425			0x600d86b0
 #define PHY_ID_BCM7429			0x600d8730
 #define PHY_ID_BCM7435			0x600d8750
-- 
2.7.4
