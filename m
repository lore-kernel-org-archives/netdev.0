From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 3/3] bnx2x: Fix KR2 work-around condition
Date: Thu, 28 Feb 2013 01:06:46 +0200
Message-ID: <1362006406-2489-4-git-send-email-yanivr@broadcom.com>
References: <1362006406-2489-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4465 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752612Ab3B0VIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 16:08:32 -0500
In-Reply-To: <1362006406-2489-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix condition typo for running KR2 work-around though it doesn't have 
real effect since the typo bits matched by chance.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index bf69c53..31c5787 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -13499,7 +13499,7 @@ void bnx2x_period_func(struct link_params *params, struct link_vars *vars)
 		struct bnx2x_phy *phy = &params->phy[INT_PHY];
 		bnx2x_set_aer_mmd(params, phy);
 		if ((phy->supported & SUPPORTED_20000baseKR2_Full) &&
-		    (phy->speed_cap_mask & SPEED_20000))
+		    (phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_20G))
 			bnx2x_check_kr2_wa(params, vars, phy);
 		bnx2x_check_over_curr(params, vars);
 		if (vars->rx_tx_asic_rst)
-- 
1.7.7.1
