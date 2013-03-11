From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 09/13] bnx2x: Add EEE support for BCM84834
Date: Mon, 11 Mar 2013 17:17:49 +0200
Message-ID: <1363015073-25743-10-git-send-email-yuvalmin@broadcom.com>
References: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4804 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754163Ab3CKQZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Mar 2013 12:25:20 -0400
In-Reply-To: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 600f850..fa027d8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -10284,7 +10284,8 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 				LINK_STATUS_LINK_PARTNER_10GXFD_CAPABLE;
 
 		/* Determine if EEE was negotiated */
-		if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833)
+		if ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) ||
+		    (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834))
 			bnx2x_eee_an_resolve(phy, params, vars);
 	}
 
-- 
1.7.7.2
