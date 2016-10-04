From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: axienet: Add missing \n to end of dev_err messages
Date: Tue,  4 Oct 2016 12:11:41 +0100
Message-ID: <20161004111141.11768-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Anirudha Sarangi <anirudh@xilinx.com>,
        John Linn <John.Linn@xilinx.com>,
        Michal Simek <michal.simek@xilinx.com>,
        =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trival fix, dev_err messages are missing a \n, so add it.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 69e2a83..35f9f97 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -818,7 +818,7 @@ static irqreturn_t axienet_tx_irq(int irq, void *_ndev)
 		goto out;
 	}
 	if (!(status & XAXIDMA_IRQ_ALL_MASK))
-		dev_err(&ndev->dev, "No interrupts asserted in Tx path");
+		dev_err(&ndev->dev, "No interrupts asserted in Tx path\n");
 	if (status & XAXIDMA_IRQ_ERROR_MASK) {
 		dev_err(&ndev->dev, "DMA Tx error 0x%x\n", status);
 		dev_err(&ndev->dev, "Current BD is at: 0x%x\n",
@@ -867,7 +867,7 @@ static irqreturn_t axienet_rx_irq(int irq, void *_ndev)
 		goto out;
 	}
 	if (!(status & XAXIDMA_IRQ_ALL_MASK))
-		dev_err(&ndev->dev, "No interrupts asserted in Rx path");
+		dev_err(&ndev->dev, "No interrupts asserted in Rx path\n");
 	if (status & XAXIDMA_IRQ_ERROR_MASK) {
 		dev_err(&ndev->dev, "DMA Rx error 0x%x\n", status);
 		dev_err(&ndev->dev, "Current BD is at: 0x%x\n",
-- 
2.9.3
