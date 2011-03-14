From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-2.6] bnx2x: fix swap of rx-ticks and tx-ticks
 parameters in interrupt coalescing flow
Date: Mon, 14 Mar 2011 13:07:20 +0200
Message-ID: <1300100840.2090.21.camel@lb-tlvb-ariel.il.broadcom.com>
Reply-To: ariele@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3534 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752092Ab1CNLBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 07:01:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index aa03233..10bc0a6 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -4208,7 +4208,7 @@ void bnx2x_update_coalesce(struct bnx2x *bp)
 
 	for_each_eth_queue(bp, i)
 		bnx2x_update_coalesce_sb(bp, bp->fp[i].fw_sb_id,
-					 bp->rx_ticks, bp->tx_ticks);
+					 bp->tx_ticks, bp->rx_ticks);
 }
 
 static void bnx2x_init_sp_ring(struct bnx2x *bp)
-- 
1.7.4.1




