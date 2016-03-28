From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 3/4] bnxt_en: Fix typo in bnxt_hwrm_set_pause_common().
Date: Mon, 28 Mar 2016 19:46:06 -0400
Message-ID: <1459208767-4225-4-git-send-email-michael.chan@broadcom.com>
References: <1459208767-4225-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:32774 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755543AbcC1Xz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 19:55:59 -0400
In-Reply-To: <1459208767-4225-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The typo caused the wrong flow control bit to be set.

Reported by: Ajit Khaparde <ajit.khaparde@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 4600a05..12a009d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4559,7 +4559,7 @@ bnxt_hwrm_set_pause_common(struct bnxt *bp, struct hwrm_port_phy_cfg_input *req)
 		if (bp->link_info.req_flow_ctrl & BNXT_LINK_PAUSE_RX)
 			req->auto_pause |= PORT_PHY_CFG_REQ_AUTO_PAUSE_RX;
 		if (bp->link_info.req_flow_ctrl & BNXT_LINK_PAUSE_TX)
-			req->auto_pause |= PORT_PHY_CFG_REQ_AUTO_PAUSE_RX;
+			req->auto_pause |= PORT_PHY_CFG_REQ_AUTO_PAUSE_TX;
 		req->enables |=
 			cpu_to_le32(PORT_PHY_CFG_REQ_ENABLES_AUTO_PAUSE);
 	} else {
-- 
1.8.3.1
