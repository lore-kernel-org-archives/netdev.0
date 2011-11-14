From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] bnx2x: add endline at end of message
Date: Mon, 14 Nov 2011 10:40:39 +0200
Message-ID: <1321260039-19254-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2798 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752086Ab1KNIkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 03:40:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Joe Perches <joe@perches.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 33ff60d..c09e59a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -8520,7 +8520,7 @@ sp_rtnl_not_reset:
 	 * damage
 	 */
 	if (test_and_clear_bit(BNX2X_SP_RTNL_FAN_FAILURE, &bp->sp_rtnl_state)) {
-		DP(BNX2X_MSG_SP, "fan failure detected. Unloading driver");
+		DP(BNX2X_MSG_SP, "fan failure detected. Unloading driver\n");
 		netif_device_detach(bp->dev);
 		bnx2x_close(bp->dev);
 	}
-- 
1.7.7.2
