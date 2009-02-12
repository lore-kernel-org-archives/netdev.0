From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 21/41]bnx2x: GMII not SGMII
Date: Thu, 12 Feb 2009 20:37:12 +0200
Message-ID: <1234463832.1863.153.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2949 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757412AbZBLSpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 21/41]bnx2x: GMII not SGMII
Fixing the function name

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 526072b..b61a7a2 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1753,7 +1753,7 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 	return rc;
 }
 
-static void bnx2x_set_sgmii_tx_driver(struct link_params *params)
+static void bnx2x_set_gmii_tx_driver(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u16 lp_up2;
@@ -4929,7 +4929,7 @@ static u8 bnx2x_update_link_up(struct link_params *params,
 		if (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) {
 			if (!(vars->phy_flags &
 			      PHY_SGMII_FLAG))
-				bnx2x_set_sgmii_tx_driver(params);
+				bnx2x_set_gmii_tx_driver(params);
 		}
 	}
 
-- 
1.5.4.3




