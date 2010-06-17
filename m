From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH v2 1/2] broadcom: move all PHY_ID's to header
Date: Thu, 17 Jun 2010 13:02:23 +0400
Message-ID: <1276765344-12675-1-git-send-email-dbaryshkov@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34516 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324Ab0FQJCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 05:02:22 -0400
Received: by fxm10 with SMTP id 10so1391832fxm.19
        for <netdev@vger.kernel.org>; Thu, 17 Jun 2010 02:02:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move all PHY IDs to brcmphy.h header for completeness and unification of code.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 drivers/net/phy/broadcom.c |   24 ++++++++++++------------
 include/linux/brcmphy.h    |    6 ++++++
 2 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index cecdbbd..b743d37 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -685,7 +685,7 @@ static int brcm_fet_config_intr(struct phy_device *phydev)
 }
 
 static struct phy_driver bcm5411_driver = {
-	.phy_id		= 0x00206070,
+	.phy_id		= PHY_ID_BCM5411,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5411",
 	.features	= PHY_GBIT_FEATURES |
@@ -700,7 +700,7 @@ static struct phy_driver bcm5411_driver = {
 };
 
 static struct phy_driver bcm5421_driver = {
-	.phy_id		= 0x002060e0,
+	.phy_id		= PHY_ID_BCM5421,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5421",
 	.features	= PHY_GBIT_FEATURES |
@@ -715,7 +715,7 @@ static struct phy_driver bcm5421_driver = {
 };
 
 static struct phy_driver bcm5461_driver = {
-	.phy_id		= 0x002060c0,
+	.phy_id		= PHY_ID_BCM5461,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5461",
 	.features	= PHY_GBIT_FEATURES |
@@ -730,7 +730,7 @@ static struct phy_driver bcm5461_driver = {
 };
 
 static struct phy_driver bcm5464_driver = {
-	.phy_id		= 0x002060b0,
+	.phy_id		= PHY_ID_BCM5464,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5464",
 	.features	= PHY_GBIT_FEATURES |
@@ -745,7 +745,7 @@ static struct phy_driver bcm5464_driver = {
 };
 
 static struct phy_driver bcm5481_driver = {
-	.phy_id		= 0x0143bca0,
+	.phy_id		= PHY_ID_BCM5481,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5481",
 	.features	= PHY_GBIT_FEATURES |
@@ -760,7 +760,7 @@ static struct phy_driver bcm5481_driver = {
 };
 
 static struct phy_driver bcm5482_driver = {
-	.phy_id		= 0x0143bcb0,
+	.phy_id		= PHY_ID_BCM5482,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5482",
 	.features	= PHY_GBIT_FEATURES |
@@ -910,12 +910,12 @@ module_init(broadcom_init);
 module_exit(broadcom_exit);
 
 static struct mdio_device_id broadcom_tbl[] = {
-	{ 0x00206070, 0xfffffff0 },
-	{ 0x002060e0, 0xfffffff0 },
-	{ 0x002060c0, 0xfffffff0 },
-	{ 0x002060b0, 0xfffffff0 },
-	{ 0x0143bca0, 0xfffffff0 },
-	{ 0x0143bcb0, 0xfffffff0 },
+	{ PHY_ID_BCM5411, 0xfffffff0 },
+	{ PHY_ID_BCM5421, 0xfffffff0 },
+	{ PHY_ID_BCM5461, 0xfffffff0 },
+	{ PHY_ID_BCM5464, 0xfffffff0 },
+	{ PHY_ID_BCM5482, 0xfffffff0 },
+	{ PHY_ID_BCM5482, 0xfffffff0 },
 	{ PHY_ID_BCM50610, 0xfffffff0 },
 	{ PHY_ID_BCM50610M, 0xfffffff0 },
 	{ PHY_ID_BCM57780, 0xfffffff0 },
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 7f437ca..c14c3a1 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -1,6 +1,12 @@
 #define PHY_ID_BCM50610			0x0143bd60
 #define PHY_ID_BCM50610M		0x0143bd70
 #define PHY_ID_BCMAC131			0x0143bc70
+#define PHY_ID_BCM5481			0x0143bca0
+#define PHY_ID_BCM5482			0x0143bcb0
+#define PHY_ID_BCM5411			0x00206070
+#define PHY_ID_BCM5421			0x002060e0
+#define PHY_ID_BCM5464			0x002060b0
+#define PHY_ID_BCM5461			0x002060c0
 #define PHY_ID_BCM57780			0x03625d90
 
 #define PHY_BCM_OUI_MASK		0xfffffc00
-- 
1.7.1

