From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: phy: bcm7xxx: add alternate id for 7439
Date: Mon,  9 Mar 2015 15:44:13 -0700
Message-ID: <1425941053-13222-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35437 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbbCIWot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 18:44:49 -0400
Received: by pdbfp1 with SMTP id fp1so47128727pdb.2
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 15:44:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BCM7439 has an alternate PHY OUI: 0xae025080 which is to be found in
some variants of this chip.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 1 +
 include/linux/brcmphy.h   | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 974ec4515269..64c74c6a4828 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -396,6 +396,7 @@ static struct phy_driver bcm7xxx_driver[] = {
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7364, "Broadcom BCM7364"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7366, "Broadcom BCM7366"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7439, "Broadcom BCM7439"),
+	BCM7XXX_28NM_GPHY(PHY_ID_BCM7439_2, "Broadcom BCM7439 (2)"),
 	BCM7XXX_28NM_GPHY(PHY_ID_BCM7445, "Broadcom BCM7445"),
 {
 	.phy_id         = PHY_ID_BCM7425,
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 7ccd928cc1f2..cab606617522 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -19,6 +19,7 @@
 #define PHY_ID_BCM7425			0x03625e60
 #define PHY_ID_BCM7429			0x600d8730
 #define PHY_ID_BCM7439			0x600d8480
+#define PHY_ID_BCM7439_2		0xae025080
 #define PHY_ID_BCM7445			0x600d8510
 
 #define PHY_BCM_OUI_MASK		0xfffffc00
-- 
2.1.0
