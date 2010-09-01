From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 7/8] bnx2x: Add BCM84823 to the supported PHYs
Date: Wed, 1 Sep 2010 22:51:35 +0300
Message-ID: <1283370695.4403.138.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1286 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755545Ab0IAQdW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 12:33:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add BCM84823 to the supported PHYs

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index b09fa04..993d7e8 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -6226,7 +6226,8 @@ static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (BCM8481)\n",
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823:
+			BNX2X_DEV_INFO("ext_phy_type 0x%x (BCM848xx)\n",
 				       ext_phy_type);
 
 			bp->port.supported |= (SUPPORTED_10baseT_Half |
-- 
1.7.1




