From: akpm@osdl.org
Subject: [patch 19/41] ni65 section fix
Date: Mon, 14 Aug 2006 23:00:07 -0700
Message-ID: <200608150600.k7F6071E012657@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:26002 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965136AbWHOGAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:16 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/ni65.o - Section mismatch: reference to .init.text:ni65_probe from .text between 'init_module' (at offset 0x54a) and 'ni65_stop_start'

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/ni65.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/ni65.c~ni65-section-fix drivers/net/ni65.c
--- a/drivers/net/ni65.c~ni65-section-fix
+++ a/drivers/net/ni65.c
@@ -1253,7 +1253,7 @@ MODULE_PARM_DESC(irq, "ni6510 IRQ number
 MODULE_PARM_DESC(io, "ni6510 I/O base address");
 MODULE_PARM_DESC(dma, "ni6510 ISA DMA channel (ignored for some cards)");
 
-int init_module(void)
+int __init init_module(void)
 {
  	dev_ni65 = ni65_probe(-1);
 	return IS_ERR(dev_ni65) ? PTR_ERR(dev_ni65) : 0;
_
