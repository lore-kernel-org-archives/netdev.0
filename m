From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: phy: bcm7xxx: Add BCM74371 PHY ID
Date: Mon,  6 Feb 2017 13:01:16 -0800
Message-ID: <20170206210116.24125-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36098 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750995AbdBFVBU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 16:01:20 -0500
Received: by mail-pf0-f195.google.com with SMTP id 19so7618459pfo.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 13:01:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the BCM74371 PHY ID to the list of supported chips. This is a 28nm
technology Gigabit PHY SoC.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 2 ++
 include/linux/brcmphy.h   | 1 +
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index aa01020ab1b9..d1c2614dad3a 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -453,6 +453,7 @@ static struct phy_driver bcm7xxx_driver[] = {
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7278, "Broadcom BCM7278"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7364, "Broadcom BCM7364"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7366, "Broadcom BCM7366"),
+	BCM7XXX_28NM_GPHY(PHY_ID_BCM74371, "Broadcom BCM74371"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7439, "Broadcom BCM7439"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7439_2, "Broadcom BCM7439 (2)"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7445, "Broadcom BCM7445"),
@@ -472,6 +473,7 @@ static struct mdio_device_id __maybe_unused bcm7xxx_tbl[] = {
 	{ PHY_ID_BCM7362, 0xfffffff0, },
 	{ PHY_ID_BCM7425, 0xfffffff0, },
 	{ PHY_ID_BCM7429, 0xfffffff0, },
+	{ PHY_ID_BCM74371, 0xfffffff0, },
 	{ PHY_ID_BCM7439, 0xfffffff0, },
 	{ PHY_ID_BCM7435, 0xfffffff0, },
 	{ PHY_ID_BCM7445, 0xfffffff0, },
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 5881d1fdc1fb..55e517130311 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -33,6 +33,7 @@
 #define PHY_ID_BCM7425			0x600d86b0
 #define PHY_ID_BCM7429			0x600d8730
 #define PHY_ID_BCM7435			0x600d8750
+#define PHY_ID_BCM74371			0xae0252e0
 #define PHY_ID_BCM7439			0x600d8480
 #define PHY_ID_BCM7439_2		0xae025080
 #define PHY_ID_BCM7445			0x600d8510
-- 
2.9.3
