From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/2] bnx2: Add "fall through" comments
Date: Wed, 27 Jun 2012 18:08:23 -0700
Message-ID: <1340845704-12580-5-git-send-email-mchan@broadcom.com>
References: <1340845704-12580-1-git-send-email-mchan@broadcom.com>
 <1340845704-12580-2-git-send-email-mchan@broadcom.com>
 <1340845704-12580-3-git-send-email-mchan@broadcom.com>
 <1340845704-12580-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3198 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932205Ab2F1A50 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 20:57:26 -0400
In-Reply-To: <1340845704-12580-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

to indicate that the mising break statements are intended.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 9b69a62..e6116ec 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -1972,22 +1972,26 @@ bnx2_remote_phy_event(struct bnx2 *bp)
 		switch (speed) {
 			case BNX2_LINK_STATUS_10HALF:
 				bp->duplex = DUPLEX_HALF;
+				/* fall through */
 			case BNX2_LINK_STATUS_10FULL:
 				bp->line_speed = SPEED_10;
 				break;
 			case BNX2_LINK_STATUS_100HALF:
 				bp->duplex = DUPLEX_HALF;
+				/* fall through */
 			case BNX2_LINK_STATUS_100BASE_T4:
 			case BNX2_LINK_STATUS_100FULL:
 				bp->line_speed = SPEED_100;
 				break;
 			case BNX2_LINK_STATUS_1000HALF:
 				bp->duplex = DUPLEX_HALF;
+				/* fall through */
 			case BNX2_LINK_STATUS_1000FULL:
 				bp->line_speed = SPEED_1000;
 				break;
 			case BNX2_LINK_STATUS_2500HALF:
 				bp->duplex = DUPLEX_HALF;
+				/* fall through */
 			case BNX2_LINK_STATUS_2500FULL:
 				bp->line_speed = SPEED_2500;
 				break;
-- 
1.7.1
