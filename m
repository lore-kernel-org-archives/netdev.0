From: Dave Jones <davej@redhat.com>
Subject: Add missing braces in bnx2x:bnx2x_link_initialize
Date: Wed, 4 Sep 2013 23:46:58 -0400
Message-ID: <20130905034658.GA12717@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eilong@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7359 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753243Ab3IEDrG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 23:47:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The indentation here implies that the intent was for this to be a multiline if.
Introduced a few years ago in commit ec146a6f019923819f5ca381980248b6d154ca1a ("bnx2x: Modify XGXS functions")

Signed-off-by: Dave Jones <davej@fedoraproject.org>

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 9d64b98..6645684 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -6501,12 +6501,13 @@ static int bnx2x_link_initialize(struct link_params *params,
 		struct bnx2x_phy *phy = &params->phy[INT_PHY];
 		if (vars->line_speed == SPEED_AUTO_NEG &&
 		    (CHIP_IS_E1x(bp) ||
-		     CHIP_IS_E2(bp)))
+		     CHIP_IS_E2(bp))) {
 			bnx2x_set_parallel_detection(phy, params);
 			if (params->phy[INT_PHY].config_init)
 				params->phy[INT_PHY].config_init(phy,
 								 params,
 								 vars);
+		}
 	}
 
 	/* Init external phy*/
