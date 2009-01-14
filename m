From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 06/34]bnx2x: Missing mask when calculating flow control
Date: Wed, 14 Jan 2009 18:42:58 +0200
Message-ID: <1231951378.11301.127.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2653 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762965AbZANQnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:43:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index da18528..39ea2fc 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1915,7 +1915,8 @@ static int bnx2x_set_spio(struct bnx2x *bp, int spio_num, u32 mode)
 
 static void bnx2x_calc_fc_adv(struct bnx2x *bp)
 {
-	switch (bp->link_vars.ieee_fc) {
+	switch (bp->link_vars.ieee_fc &
+		MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK) {
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE:
 		bp->port.advertising &= ~(ADVERTISED_Asym_Pause |
 					  ADVERTISED_Pause);
-- 
1.5.4.3




