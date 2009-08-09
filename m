From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: [PATCH] net: smc911x: includecheck fix for smc911x.h
Date: Sun, 09 Aug 2009 18:42:38 +0530
Message-ID: <1249823558.2957.8.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, nico@cam.org,
	netdev <netdev@vger.kernel.org>, dustin@sensoria.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:34670 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751794AbZHINOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2009 09:14:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


fix the following 'make includecheck' warning:

  drivers/net/smc911x.h: mach/dma.h is included more than once.

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 drivers/net/smc911x.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index 8140f7c..05adb6a 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -236,7 +236,6 @@ static inline void SMC_outsl(struct smc911x_local *lp, int reg,
  * Use a DMA for RX and TX packets.
  */
 #include <linux/dma-mapping.h>
-#include <mach/dma.h>
 
 static dma_addr_t rx_dmabuf, tx_dmabuf;
 static int rx_dmalen, tx_dmalen;
-- 
1.6.0.6



