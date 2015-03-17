From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 02/16 linux-next] Altera TSE: constify of_device_id array
Date: Tue, 17 Mar 2015 19:37:33 +0100
Message-ID: <1426617469-781-3-git-send-email-fabf@skynet.be>
References: <1426617469-781-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	Vince Bridgers <vbridger@opensource.altera.com>,
	netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426617469-781-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

of_device_id is always used as const.
(See driver.of_match_table and open firmware functions)

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index fd9296a..79ea358 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -89,7 +89,7 @@ MODULE_PARM_DESC(dma_tx_num, "Number of descriptors in the TX list");
 
 #define TXQUEUESTOP_THRESHHOLD	2
 
-static struct of_device_id altera_tse_ids[];
+static const struct of_device_id altera_tse_ids[];
 
 static inline u32 tse_tx_avail(struct altera_tse_private *priv)
 {
@@ -1576,7 +1576,7 @@ static const struct altera_dmaops altera_dtype_msgdma = {
 	.start_rxdma = msgdma_start_rxdma,
 };
 
-static struct of_device_id altera_tse_ids[] = {
+static const struct of_device_id altera_tse_ids[] = {
 	{ .compatible = "altr,tse-msgdma-1.0", .data = &altera_dtype_msgdma, },
 	{ .compatible = "altr,tse-1.0", .data = &altera_dtype_sgdma, },
 	{ .compatible = "ALTR,tse-1.0", .data = &altera_dtype_sgdma, },
-- 
2.1.0
