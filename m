From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 14/18] bnx2x: Loopback support at external PHY
Date: Mon, 02 Mar 2009 20:01:02 +0200
Message-ID: <1236016862.7723.86.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4812 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756698AbZCBSBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:01:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 14/18] bnx2x: Loopback support at external PHY

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 3812058..ed648ac 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -4624,13 +4624,13 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 
 	/* init ext phy and enable link state int */
 	non_ext_phy = ((ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) ||
-		       (params->loopback_mode == LOOPBACK_XGXS_10) ||
-		       (params->loopback_mode == LOOPBACK_EXT_PHY));
+		       (params->loopback_mode == LOOPBACK_XGXS_10));
 
 	if (non_ext_phy ||
 	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
 	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) ||
-	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481)) {
+	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481) ||
+	    (params->loopback_mode == LOOPBACK_EXT_PHY)) {
 		if (params->req_line_speed == SPEED_AUTO_NEG)
 			bnx2x_set_parallel_detection(params, vars->phy_flags);
 		bnx2x_init_internal_phy(params, vars);
-- 
1.5.4.3




