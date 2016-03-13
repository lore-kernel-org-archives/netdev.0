From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: [PATCH 5/5] net: macb: Fix simple typo.
Date: Sun, 13 Mar 2016 12:10:47 -0700
Message-ID: <1457896247-25934-6-git-send-email-moritz.fischer@ettus.com>
References: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
Cc: michal.simek@xilinx.com, joe@perches.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	moritz.fischer.private@gmail.com,
	Moritz Fischer <moritz.fischer@ettus.com>
To: nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33553 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbcCMTLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 15:11:09 -0400
Received: by mail-pa0-f47.google.com with SMTP id fl4so139522621pad.0
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2016 12:11:09 -0700 (PDT)
In-Reply-To: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Moritz Fischer <moritz.fischer@ettus.com>
---
 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index a0c01e5..681e5bf 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -127,7 +127,7 @@ static void hw_writel(struct macb *bp, int offset, u32 value)
 }
 
 /* Find the CPU endianness by using the loopback bit of NCR register. When the
- * CPU is in big endian we need to program swaped mode for management
+ * CPU is in big endian we need to program swapped mode for management
  * descriptor access.
  */
 static bool hw_is_native_io(void __iomem *addr)
-- 
2.4.3
