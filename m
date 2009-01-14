From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 07/34]bnx2x: Flow control updated before reporting the
 link
Date: Wed, 14 Jan 2009 18:43:02 +0200
Message-ID: <1231951382.11301.128.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1340 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762877AbZANQnx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:43:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 39ea2fc..56eae2d 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1986,10 +1986,11 @@ static u8 bnx2x_initial_phy_init(struct bnx2x *bp)
 		rc = bnx2x_phy_init(&bp->link_params, &bp->link_vars);
 		bnx2x_release_phy_lock(bp);
 
+		bnx2x_calc_fc_adv(bp);
+
 		if (bp->link_vars.link_up)
 			bnx2x_link_report(bp);
 
-		bnx2x_calc_fc_adv(bp);
 
 		return rc;
 	}
-- 
1.5.4.3




