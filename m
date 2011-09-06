From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 3/6] bnx2x: Remove fiber remote fault detection
Date: Tue, 6 Sep 2011 09:47:11 +0300
Message-ID: <1315291631.28564.17.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3538 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752961Ab1IFGrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Sep 2011 02:47:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove remote fault detection as a tactic retreat due to link issues involved with it.
Once issue is resolved, this feature will be restored again.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index f7a7ac3..db5913d 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -10638,8 +10638,7 @@ static struct bnx2x_phy phy_warpcore = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT,
 	.addr		= 0xff,
 	.def_md_devad	= 0,
-	.flags		= (FLAGS_HW_LOCK_REQUIRED |
-			   FLAGS_TX_ERROR_CHECK),
+	.flags		= FLAGS_HW_LOCK_REQUIRED,
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
@@ -10765,8 +10764,7 @@ static struct bnx2x_phy phy_8706 = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706,
 	.addr		= 0xff,
 	.def_md_devad	= 0,
-	.flags		= (FLAGS_INIT_XGXS_FIRST |
-			   FLAGS_TX_ERROR_CHECK),
+	.flags		= FLAGS_INIT_XGXS_FIRST,
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
@@ -10797,8 +10795,7 @@ static struct bnx2x_phy phy_8726 = {
 	.addr		= 0xff,
 	.def_md_devad	= 0,
 	.flags		= (FLAGS_HW_LOCK_REQUIRED |
-			   FLAGS_INIT_XGXS_FIRST |
-			   FLAGS_TX_ERROR_CHECK),
+			   FLAGS_INIT_XGXS_FIRST),
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
@@ -10829,8 +10826,7 @@ static struct bnx2x_phy phy_8727 = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
 	.addr		= 0xff,
 	.def_md_devad	= 0,
-	.flags		= (FLAGS_FAN_FAILURE_DET_REQ |
-			   FLAGS_TX_ERROR_CHECK),
+	.flags		= FLAGS_FAN_FAILURE_DET_REQ,
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
-- 
1.7.1
