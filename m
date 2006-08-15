From: akpm@osdl.org
Subject: [patch 15/41] ni52 section fix
Date: Mon, 14 Aug 2006 23:00:05 -0700
Message-ID: <200608150600.k7F605Jd012645@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25490 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965134AbWHOGAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:15 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/ni52.o - Section mismatch: reference to .init.text:ni52_probe from .text between 'init_module' (at offset 0x997) and 'ni52_close'
WARNING: drivers/net/ni65.o - Section mismatch: reference to .init.text:ni65_probe from .text between 'init_module' (at offset 0x54a) and 'ni65_stop_start'

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/ni52.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/ni52.c~ni52-section-fix drivers/net/ni52.c
--- a/drivers/net/ni52.c~ni52-section-fix
+++ a/drivers/net/ni52.c
@@ -1323,7 +1323,7 @@ MODULE_PARM_DESC(irq, "NI5210 IRQ number
 MODULE_PARM_DESC(memstart, "NI5210 memory base address,required");
 MODULE_PARM_DESC(memend, "NI5210 memory end address,required");
 
-int init_module(void)
+int __init init_module(void)
 {
 	if(io <= 0x0 || !memend || !memstart || irq < 2) {
 		printk("ni52: Autoprobing not allowed for modules.\nni52: Set symbols 'io' 'irq' 'memstart' and 'memend'\n");
_
