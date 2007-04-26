From: akpm@linux-foundation.org
Subject: [patch 05/11] vioc: replace more deprecated SA_xxx interrupt flags
Date: Thu, 26 Apr 2007 00:23:17 -0700
Message-ID: <200704260723.l3Q7NHeg023832@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	tglx@linutronix.de, schidambaram@fabric7.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:34328 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933325AbXDZHYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:24:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

Fix the obnoxious users of the deprecated SA_xxx interrupt flags.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Sriram Chidambaram <schidambaram@fabric7.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/vioc/vioc_irq.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/vioc/vioc_irq.c~vioc-replace-more-deprecated-sa_xxx-interrupt-flags drivers/net/vioc/vioc_irq.c
--- a/drivers/net/vioc/vioc_irq.c~vioc-replace-more-deprecated-sa_xxx-interrupt-flags
+++ a/drivers/net/vioc/vioc_irq.c
@@ -319,7 +319,7 @@ static int vioc_irq_install(struct pci_d
 
 	ret = request_irq(vioc_interrupts[vioc_id].intreq[intr_id].irq,
 			  vioc_interrupts[vioc_id].intreq[intr_id].hthandler,
-			  SA_INTERRUPT,
+			  IRQF_DISABLED,
 			  vioc_interrupts[vioc_id].intreq[intr_id].name,
 			  vioc_interrupts[vioc_id].intreq[intr_id].
 			  intrFuncparm);
_
