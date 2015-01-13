From: <shh.xie@gmail.com>
Subject: [PATCH] net/fsl: replace (1 << x) with BIT(x) for bit definitions in xgmac_mdio
Date: Tue, 13 Jan 2015 10:30:59 +0800
Message-ID: <1421116259-16152-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0063.outbound.protection.outlook.com ([157.56.110.63]:13568
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751511AbbAMDhC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2015 22:37:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/ethernet/freescale/xgmac_mdio.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index a492e50..3a76e23 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -34,17 +34,17 @@ struct tgec_mdio_controller {
 
 #define MDIO_STAT_ENC		BIT(6)
 #define MDIO_STAT_CLKDIV(x)	(((x>>1) & 0xff) << 8)
-#define MDIO_STAT_BSY		(1 << 0)
-#define MDIO_STAT_RD_ER		(1 << 1)
+#define MDIO_STAT_BSY		BIT(0)
+#define MDIO_STAT_RD_ER		BIT(1)
 #define MDIO_CTL_DEV_ADDR(x) 	(x & 0x1f)
 #define MDIO_CTL_PORT_ADDR(x)	((x & 0x1f) << 5)
-#define MDIO_CTL_PRE_DIS	(1 << 10)
-#define MDIO_CTL_SCAN_EN	(1 << 11)
-#define MDIO_CTL_POST_INC	(1 << 14)
-#define MDIO_CTL_READ		(1 << 15)
+#define MDIO_CTL_PRE_DIS	BIT(10)
+#define MDIO_CTL_SCAN_EN	BIT(11)
+#define MDIO_CTL_POST_INC	BIT(14)
+#define MDIO_CTL_READ		BIT(15)
 
 #define MDIO_DATA(x)		(x & 0xffff)
-#define MDIO_DATA_BSY		(1 << 31)
+#define MDIO_DATA_BSY		BIT(31)
 
 /*
  * Wait until the MDIO bus is free
-- 
1.8.4.1
