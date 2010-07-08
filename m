From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] b44: remove unused dma_desc_align_mask
Date: Thu, 8 Jul 2010 09:55:58 +0900
Message-ID: <20100708095537B.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:50645 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755609Ab0GHA4D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jul 2010 20:56:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/b44.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 3d52538..37617ab 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -135,7 +135,6 @@ static void b44_init_rings(struct b44 *);
 
 static void b44_init_hw(struct b44 *, int);
 
-static int dma_desc_align_mask;
 static int dma_desc_sync_size;
 static int instance;
 
@@ -2340,7 +2339,6 @@ static int __init b44_init(void)
 	int err;
 
 	/* Setup paramaters for syncing RX/TX DMA descriptors */
-	dma_desc_align_mask = ~(dma_desc_align_size - 1);
 	dma_desc_sync_size = max_t(unsigned int, dma_desc_align_size, sizeof(struct dma_desc));
 
 	err = b44_pci_init();
-- 
1.6.5

