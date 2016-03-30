From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: [PATCH v3 5/5] net: macb: Fix simple typo
Date: Tue, 29 Mar 2016 19:11:15 -0700
Message-ID: <1459303875-3362-6-git-send-email-moritz.fischer@ettus.com>
References: <1459303875-3362-1-git-send-email-moritz.fischer@ettus.com>
Cc: michal.simek@xilinx.com, joe@perches.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	moritz.fischer.private@gmail.com,
	Moritz Fischer <moritz.fischer@ettus.com>
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459303875-3362-1-git-send-email-moritz.fischer@ettus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by: Michal Simek <michal.simek@xilinx.com>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Signed-off-by: Moritz Fischer <moritz.fischer@ettus.com>
---
 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 01a8ffb..eec3200 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -130,7 +130,7 @@ static void hw_writel(struct macb *bp, int offset, u32 value)
 }
 
 /* Find the CPU endianness by using the loopback bit of NCR register. When the
- * CPU is in big endian we need to program swaped mode for management
+ * CPU is in big endian we need to program swapped mode for management
  * descriptor access.
  */
 static bool hw_is_native_io(void __iomem *addr)
-- 
2.7.4
