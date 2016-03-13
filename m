From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: [PATCH 1/5] net: macb: Fix coding style error message
Date: Sun, 13 Mar 2016 12:10:43 -0700
Message-ID: <1457896247-25934-2-git-send-email-moritz.fischer@ettus.com>
References: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
Cc: michal.simek@xilinx.com, joe@perches.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	moritz.fischer.private@gmail.com,
	Moritz Fischer <moritz.fischer@ettus.com>
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

checkpatch.pl gave the following error:

ERROR: space required before the open parenthesis '('
+	for(; p < end; p++, offset += 4)

Signed-off-by: Moritz Fischer <moritz.fischer@ettus.com>
---
 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 50c9410..4370f37 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -496,7 +496,7 @@ static void macb_update_stats(struct macb *bp)
 
 	WARN_ON((unsigned long)(end - p - 1) != (MACB_TPF - MACB_PFR) / 4);
 
-	for(; p < end; p++, offset += 4)
+	for (; p < end; p++, offset += 4)
 		*p += bp->macb_reg_readl(bp, offset);
 }
 
-- 
2.4.3
