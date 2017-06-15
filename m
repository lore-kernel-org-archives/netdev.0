From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: s2io: remove useless variable in fill_rx_buffers
Date: Wed, 14 Jun 2017 21:58:17 -0500
Message-ID: <20170615025817.GA11511@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Jon Mason <jdmason@kudzu.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove useless variable rxd_index and code related.

Addresses-Coverity-ID: 1397691
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/net/ethernet/neterion/s2io.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 118723e..fd2ec36 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -2459,7 +2459,6 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 	struct buffAdd *ba;
 	struct RxD_t *first_rxdp = NULL;
 	u64 Buffer0_ptr = 0, Buffer1_ptr = 0;
-	int rxd_index = 0;
 	struct RxD1 *rxdp1;
 	struct RxD3 *rxdp3;
 	struct swStat *swstats = &ring->nic->mac_control.stats_info->sw_stat;
@@ -2474,10 +2473,6 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 
 		rxdp = ring->rx_blocks[block_no].rxds[off].virt_addr;
 
-		rxd_index = off + 1;
-		if (block_no)
-			rxd_index += (block_no * ring->rxd_count);
-
 		if ((block_no == block_no1) &&
 		    (off == ring->rx_curr_get_info.offset) &&
 		    (rxdp->Host_Control)) {
-- 
2.5.0
