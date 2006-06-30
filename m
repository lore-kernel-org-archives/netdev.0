From: akpm@osdl.org
Subject: [patch 5/5] Fix a warning in ioatdma
Date: Fri, 30 Jun 2006 02:27:23 -0700
Message-ID: <200606300927.k5U9RN8m001468@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, bboissin@gmail.com,
	benoit.boissinot@ens-lyon.org, christopher.leech@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:34960 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751692AbWF3J1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 05:27:34 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Benoit Boissinot" <bboissin@gmail.com>

drivers/dma/ioatdma.c: In function 'ioat_init_module':
drivers/dma/ioatdma.c:830: warning: control reaches end of non-void function

Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Cc: "Chris Leech" <christopher.leech@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/dma/ioatdma.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/dma/ioatdma.c~fix-a-warning-in-ioatdma drivers/dma/ioatdma.c
--- a/drivers/dma/ioatdma.c~fix-a-warning-in-ioatdma
+++ a/drivers/dma/ioatdma.c
@@ -826,7 +826,7 @@ static int __init ioat_init_module(void)
 	/* if forced, worst case is that rmmod hangs */
 	__unsafe(THIS_MODULE);
 
-	pci_module_init(&ioat_pci_drv);
+	return pci_module_init(&ioat_pci_drv);
 }
 
 module_init(ioat_init_module);
_
