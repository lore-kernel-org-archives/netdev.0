From: akpm@osdl.org
Subject: [patch 2/5] IOAT: fix sparse ulong warning
Date: Fri, 30 Jun 2006 02:27:20 -0700
Message-ID: <200606300927.k5U9RK0P001458@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, rdunlap@xenotime.net,
	christopher.leech@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30352 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751688AbWF3J11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 05:27:27 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Fix sparse warning:
drivers/dma/ioatdma.c:444:32: warning: constant 0xFFFFFFFFFFFFFFC0 is so big it is unsigned long

Also needs a MAINTAINERS entry.

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
Cc: Chris Leech <christopher.leech@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/dma/ioatdma_registers.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/dma/ioatdma_registers.h~ioat-fix-sparse-ulong-warning drivers/dma/ioatdma_registers.h
--- a/drivers/dma/ioatdma_registers.h~ioat-fix-sparse-ulong-warning
+++ a/drivers/dma/ioatdma_registers.h
@@ -76,7 +76,7 @@
 #define IOAT_CHANSTS_OFFSET			0x04	/* 64-bit Channel Status Register */
 #define IOAT_CHANSTS_OFFSET_LOW			0x04
 #define IOAT_CHANSTS_OFFSET_HIGH		0x08
-#define IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR	0xFFFFFFFFFFFFFFC0
+#define IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR	0xFFFFFFFFFFFFFFC0UL
 #define IOAT_CHANSTS_SOFT_ERR			0x0000000000000010
 #define IOAT_CHANSTS_DMA_TRANSFER_STATUS	0x0000000000000007
 #define IOAT_CHANSTS_DMA_TRANSFER_STATUS_ACTIVE	0x0
_
