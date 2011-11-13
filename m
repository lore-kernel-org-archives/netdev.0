From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v3 net-next 03/12] bnx2x: remove unused variable
Date: Sun, 13 Nov 2011 16:34:23 +0200
Message-ID: <1321194872-8276-4-git-send-email-dmitry@broadcom.com>
References: <1321194872-8276-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4899 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754035Ab1KMOep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Nov 2011 09:34:45 -0500
In-Reply-To: <1321194872-8276-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 1ace946..f946a6e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1094,13 +1094,11 @@ static void bnx2x_free_tx_skbs(struct bnx2x *bp)
 		for_each_cos_in_tx_queue(fp, cos) {
 			struct bnx2x_fp_txdata *txdata = &fp->txdata[cos];
 
-			u16 bd_cons = txdata->tx_bd_cons;
 			u16 sw_prod = txdata->tx_pkt_prod;
 			u16 sw_cons = txdata->tx_pkt_cons;
 
 			while (sw_cons != sw_prod) {
-				bd_cons = bnx2x_free_tx_pkt(bp, txdata,
-							    TX_BD(sw_cons));
+				bnx2x_free_tx_pkt(bp, txdata, TX_BD(sw_cons));
 				sw_cons++;
 			}
 		}
-- 
1.7.7.2
