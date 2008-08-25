From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 2/9] bnx2x: Fan failure mechanism on additional design
Date: Mon, 25 Aug 2008 17:24:30 +0300
Message-ID: <1219674270.19456.28.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3952 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753947AbYHYOZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2008 10:25:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fan failure mechanism on additional design
The A1021G board is also using the fan failure mechanism in the same way
the A1022G board does

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 272f5d1..2e207b8 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2550,6 +2550,7 @@ static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 		BNX2X_ERR("SPIO5 hw attention\n");
 
 		switch (bp->common.board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
+		case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1021G:
 		case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
 			/* Fan failure attention */
 
@@ -5337,6 +5338,7 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	}
 
 	switch (bp->common.board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
+	case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1021G:
 	case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
 		/* Fan failure is indicated by SPIO 5 */
 		bnx2x_set_spio(bp, MISC_REGISTERS_SPIO_5,
@@ -5531,6 +5533,7 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	/* Port DMAE comes here */
 
 	switch (bp->common.board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
+	case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1021G:
 	case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
 		/* add SPIO 5 to group 0 */
 		val = REG_RD(bp, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
-- 
1.5.3.2




