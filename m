From: Jongsung Kim <neidhard.kim@lge.com>
Subject: [PATCH] net/cadence/macb: fix bug/typo in extracting gem_irq_read_clear bit
Date: Tue,  9 Jul 2013 17:36:00 +0900
Message-ID: <1373358960-10900-1-git-send-email-neidhard.kim@lge.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, Jongsung Kim <neidhard.kim@lge.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jongsung Kim <neidhard.kim@lge.com>
---
 drivers/net/ethernet/cadence/macb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index c89aa41..b4e0dc8 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1070,7 +1070,7 @@ static void macb_configure_dma(struct macb *bp)
 static void macb_configure_caps(struct macb *bp)
 {
 	if (macb_is_gem(bp)) {
-		if (GEM_BF(IRQCOR, gem_readl(bp, DCFG1)) == 0)
+		if (GEM_BFEXT(IRQCOR, gem_readl(bp, DCFG1)) == 0)
 			bp->caps |= MACB_CAPS_ISR_CLEAR_ON_WRITE;
 	}
 }
-- 
1.7.1
