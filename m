From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 09/10] bnx2x: Fix BCM578xx MAC test
Date: Wed, 3 Aug 2011 12:00:06 +0300
Message-ID: <1312362006.21665.99.camel@lb-tlvb-dmitry.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2836 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752804Ab1HCJAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 05:00:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 5e6f351..01fb92c 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -11541,13 +11541,12 @@ void bnx2x_init_xmac_loopback(struct link_params *params,
 	 * Set WC to loopback mode since link is required to provide clock
 	 * to the XMAC in 20G mode
 	 */
-	if (vars->line_speed == SPEED_20000) {
-		bnx2x_set_aer_mmd(params, &params->phy[0]);
-		bnx2x_warpcore_reset_lane(bp, &params->phy[0], 0);
-		params->phy[INT_PHY].config_loopback(
+	bnx2x_set_aer_mmd(params, &params->phy[0]);
+	bnx2x_warpcore_reset_lane(bp, &params->phy[0], 0);
+	params->phy[INT_PHY].config_loopback(
 			&params->phy[INT_PHY],
 			params);
-	}
+
 	bnx2x_xmac_enable(params, vars, 1);
 	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
 }
-- 
1.7.1





