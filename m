From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: amd-xgbe: use correct format specifier
Date: Sun, 31 Jul 2016 10:07:18 +0200
Message-ID: <1469952438-20493-1-git-send-email-xypron.glpk@gmx.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

i has been defined as unsigned int.
So use %u for output.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index ebf9224..a9b2709 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -154,7 +154,7 @@ static int xgbe_alloc_channels(struct xgbe_prv_data *pdata)
 		goto err_rx_ring;
 
 	for (i = 0, channel = channel_mem; i < count; i++, channel++) {
-		snprintf(channel->name, sizeof(channel->name), "channel-%d", i);
+		snprintf(channel->name, sizeof(channel->name), "channel-%u", i);
 		channel->pdata = pdata;
 		channel->queue_index = i;
 		channel->dma_regs = pdata->xgmac_regs + DMA_CH_BASE +
-- 
2.8.1
