From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 13/20] tg3: Add 50610M phy ID for 5785
Date: Mon, 2 Nov 2009 16:29:34 -0800
Message-ID: <1257212003.22019@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3428 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757598AbZKCBd3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 20:33:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the 50610M phy ID for 5785.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    2 ++
 drivers/net/tg3.h |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7bebb47..0aecd07 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -940,6 +940,7 @@ static void tg3_mdio_config_5785(struct tg3 *tp)
 	phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
 	switch (phydev->drv->phy_id & phydev->drv->phy_id_mask) {
 	case TG3_PHY_ID_BCM50610:
+	case TG3_PHY_ID_BCM50610M:
 		val = MAC_PHYCFG2_50610_LED_MODES;
 		break;
 	case TG3_PHY_ID_BCMAC131:
@@ -1098,6 +1099,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 		phydev->interface = PHY_INTERFACE_MODE_GMII;
 		break;
 	case TG3_PHY_ID_BCM50610:
+	case TG3_PHY_ID_BCM50610M:
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE)
 			phydev->dev_flags |= PHY_BRCM_STD_IBND_DISABLE;
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_RX_EN)
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 9999345..d770da1 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2864,6 +2864,7 @@ struct tg3 {
 #define PHY_REV_BCM5401_C0		0x6
 #define PHY_REV_BCM5411_X0		0x1 /* Found on Netgear GA302T */
 #define TG3_PHY_ID_BCM50610		0x143bd60
+#define TG3_PHY_ID_BCM50610M	0x143bd70
 #define TG3_PHY_ID_BCMAC131		0x143bc70
 #define TG3_PHY_ID_RTL8211C		0x001cc910
 #define TG3_PHY_ID_RTL8201E		0x00008200
-- 
1.6.4.4


