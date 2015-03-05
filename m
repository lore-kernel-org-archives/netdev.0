From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 1/2] net: macb: Include multi queue support for xilinx ZynqMP ethernet version
Date: Thu,  5 Mar 2015 14:04:11 +0100
Message-ID: <c4d6dd80406da35180f2f4fc163b1c7fc526d92a.1425560649.git.michal.simek@xilinx.com>
Cc: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>

Include multi queue support for the ethernet IP version in xilinx ZynqMP
SoC.

Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index ad76b8e35a00..24b1eb466e52 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2192,7 +2192,7 @@ static void macb_probe_queues(void __iomem *mem,
 
 	/* is it macb or gem ? */
 	mid = __raw_readl(mem + MACB_MID);
-	if (MACB_BFEXT(IDNUM, mid) != 0x2)
+	if (MACB_BFEXT(IDNUM, mid) < 0x2)
 		return;
 
 	/* bit 0 is never set but queue 0 always exists */
-- 
1.8.2.3
