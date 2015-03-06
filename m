From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2 1/2] net: macb: Include multi queue support for xilinx ZynqMP ethernet version
Date: Fri,  6 Mar 2015 18:29:11 +0100
Message-ID: <299bfd8acf19df0b4407f98caf5130c1823cf8ad.1425662901.git.michal.simek@xilinx.com>
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
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---

Changes in v2:
- Rebase on net-next
- Add Nilocas ACK

 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 1fe8b946243a..0436aefa49e4 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2211,7 +2211,7 @@ static void macb_probe_queues(void __iomem *mem,
 	/* is it macb or gem ? */
 	mid = readl_relaxed(mem + MACB_MID);
 
-	if (MACB_BFEXT(IDNUM, mid) != 0x2)
+	if (MACB_BFEXT(IDNUM, mid) < 0x2)
 		return;
 
 	/* bit 0 is never set but queue 0 always exists */
-- 
1.8.2.3
