From: <shh.xie@gmail.com>
Subject: [PATCH] net: phy: add RealTek RTL8211DN phy id
Date: Thu, 6 Aug 2015 19:03:35 +0800
Message-ID: <1438859015-21706-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0054.outbound.protection.outlook.com ([207.46.100.54]:31968
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754137AbbHFLJQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2015 07:09:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

RTL8211DN is compatible with RTL8211E.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/phy/realtek.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 4535361..43ab691 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -137,6 +137,19 @@ static struct phy_driver realtek_drvs[] = {
 		.config_intr	= &rtl8211b_config_intr,
 		.driver		= { .owner = THIS_MODULE,},
 	}, {
+		.phy_id		= 0x001cc914,
+		.name		= "RTL8211DN Gigabit Ethernet",
+		.phy_id_mask	= 0x001fffff,
+		.features	= PHY_GBIT_FEATURES,
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_aneg	= genphy_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= rtl821x_ack_interrupt,
+		.config_intr	= rtl8211e_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+		.driver		= { .owner = THIS_MODULE,},
+	}, {
 		.phy_id		= 0x001cc915,
 		.name		= "RTL8211E Gigabit Ethernet",
 		.phy_id_mask	= 0x001fffff,
@@ -170,6 +183,7 @@ module_phy_driver(realtek_drvs);
 
 static struct mdio_device_id __maybe_unused realtek_tbl[] = {
 	{ 0x001cc912, 0x001fffff },
+	{ 0x001cc914, 0x001fffff },
 	{ 0x001cc915, 0x001fffff },
 	{ 0x001cc916, 0x001fffff },
 	{ }
-- 
2.1.0.27.g96db324
