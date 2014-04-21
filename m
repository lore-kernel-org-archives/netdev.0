From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] neterion/s2io: remove unused s2io_start_tx_queue routine
Date: Mon, 21 Apr 2014 11:13:02 +0800
Message-ID: <1398049982-8116-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55844 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbaDUDNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2014 23:13:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 drivers/net/ethernet/neterion/s2io.c |    9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index a2844ff..e900c1a 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -534,15 +534,6 @@ static inline void s2io_start_all_tx_queue(struct s2io_nic *sp)
 	netif_tx_start_all_queues(sp->dev);
 }
 
-static inline void s2io_start_tx_queue(struct s2io_nic *sp, int fifo_no)
-{
-	if (!sp->config.multiq)
-		sp->mac_control.fifos[fifo_no].queue_state =
-			FIFO_QUEUE_START;
-
-	netif_tx_start_all_queues(sp->dev);
-}
-
 static inline void s2io_wake_all_tx_queue(struct s2io_nic *sp)
 {
 	if (!sp->config.multiq) {
-- 
1.7.9.5
