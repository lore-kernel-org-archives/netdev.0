From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: [PATCH 25/44] includecheck fix: drivers/net, smc911x.h
Date: Wed, 08 Jul 2009 20:55:29 +0530
Message-ID: <1247066729.4382.72.camel@ht.satnam>
References: <1247063308.4382.12.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, nico@cam.org,
	netdev <netdev@vger.kernel.org>, Sam Ravnborg <sam@ravnborg.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:53170 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756364AbZGHQED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2009 12:04:03 -0400
In-Reply-To: <1247063308.4382.12.camel@ht.satnam>
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



