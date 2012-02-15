From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 04/11] bnx2x: added autoneg-restart after link
 advertisement changes
Date: Wed, 15 Feb 2012 07:10:25 -0500
Message-ID: <1329307832-32454-5-git-send-email-yuvalmin@broadcom.com>
References: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Mintz Yuval" <yuvalmin@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4937 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941Ab2BOFQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 00:16:10 -0500
In-Reply-To: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mintz Yuval <yuvalmin@broadcom.com>

From: Yaniv Rosner <yaniv.rosner@broadcom.com>

Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index fba4c41..acc9649 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3793,7 +3793,7 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 
 	/* Enable Autoneg */
 	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-			 MDIO_WC_REG_IEEE0BLK_MIICNTL, 0x1000);
+			 MDIO_WC_REG_IEEE0BLK_MIICNTL, 0x1200);
 
 }
 
-- 
1.7.9.rc2
