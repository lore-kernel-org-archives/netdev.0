From: akpm@osdl.org
Subject: [patch 04/11] drivers/net/acenic.c Removal of old code
Date: Mon, 25 Sep 2006 16:39:19 -0700
Message-ID: <200609252339.k8PNdJ4x002631@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	michal.k.k.piotrowski@gmail.com, jes@trained-monkey.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13492 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751714AbWIYXj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 19:39:29 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Jes Sorensen <jes@trained-monkey.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/acenic.c |    4 ----
 1 file changed, 4 deletions(-)

diff -puN drivers/net/acenic.c~drivers-net-acenicc-removal-of-old-code drivers/net/acenic.c
--- a/drivers/net/acenic.c~drivers-net-acenicc-removal-of-old-code
+++ a/drivers/net/acenic.c
@@ -163,11 +163,7 @@ MODULE_DEVICE_TABLE(pci, acenic_pci_tbl)
 #define SET_NETDEV_DEV(net, pdev)	do{} while(0)
 #endif
 
-#if LINUX_VERSION_CODE >= 0x2051c
 #define ace_sync_irq(irq)	synchronize_irq(irq)
-#else
-#define ace_sync_irq(irq)	synchronize_irq()
-#endif
 
 #ifndef offset_in_page
 #define offset_in_page(ptr)	((unsigned long)(ptr) & ~PAGE_MASK)
_
