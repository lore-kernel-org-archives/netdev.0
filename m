From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 04/11] atl1c: remove dmar_dly_cnt and dmaw_dly_cnt
Date: Thu, 19 Apr 2012 16:01:24 +0800
Message-ID: <1334822491-30129-5-git-send-email-xiong@qca.qualcomm.com>
References: <1334822491-30129-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334822491-30129-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dmar_dly_cnt and dmaw_dly_cnt aren't used by hardware/driver any more.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c.h      |    2 --
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    2 --
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h b/drivers/net/ethernet/atheros/atl1c/atl1c.h
index fa31551..acc2956 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
@@ -382,8 +382,6 @@ struct atl1c_hw {
 	u16 phy_id2;
 
 	u32 intr_mask;
-	u8 dmaw_dly_cnt;
-	u8 dmar_dly_cnt;
 
 	u8 preamble_len;
 	u16 max_frame_size;
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index e8e9c10..12b4725 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -745,8 +745,6 @@ static int __devinit atl1c_sw_init(struct atl1c_adapter *adapter)
 	hw->rfd_burst = 8;
 	hw->dma_order = atl1c_dma_ord_out;
 	hw->dmar_block = atl1c_dma_req_1024;
-	hw->dmar_dly_cnt = 15;
-	hw->dmaw_dly_cnt = 4;
 
 	if (atl1c_alloc_queues(adapter)) {
 		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
-- 
1.7.7
