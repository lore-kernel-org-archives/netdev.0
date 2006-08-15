From: akpm@osdl.org
Subject: [patch 07/41] at1700 section fix
Date: Mon, 14 Aug 2006 22:59:59 -0700
Message-ID: <200608150600.k7F5xxNs012592@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:1427 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965155AbWHOGB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:01:56 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/at1700.o - Section mismatch: reference to .init.text:at1700_probe from .text between 'init_module' (at offset 0x75) and 'net_get_stats'

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/at1700.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/at1700.c~at1700-section-fix drivers/net/at1700.c
--- a/drivers/net/at1700.c~at1700-section-fix
+++ a/drivers/net/at1700.c
@@ -901,7 +901,7 @@ MODULE_PARM_DESC(io, "AT1700/FMV18X I/O 
 MODULE_PARM_DESC(irq, "AT1700/FMV18X IRQ number");
 MODULE_PARM_DESC(net_debug, "AT1700/FMV18X debug level (0-6)");
 
-int init_module(void)
+int __init init_module(void)
 {
 	if (io == 0)
 		printk("at1700: You should not use auto-probing with insmod!\n");
_
