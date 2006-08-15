From: akpm@osdl.org
Subject: [patch 13/41] lance section fix
Date: Mon, 14 Aug 2006 23:00:03 -0700
Message-ID: <200608150600.k7F603Pv012639@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:21650 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965128AbWHOGAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:11 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/lance.o - Section mismatch: reference to .init.data:lance_portlist from .text between 'init_module' (at offset 0x8d3) and 'lance_purge_ring'
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/lance.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/lance.c~lance-section-fix drivers/net/lance.c
--- a/drivers/net/lance.c~lance-section-fix
+++ a/drivers/net/lance.c
@@ -326,7 +326,7 @@ MODULE_PARM_DESC(dma, "LANCE/PCnet ISA D
 MODULE_PARM_DESC(irq, "LANCE/PCnet IRQ number (ignored for some devices)");
 MODULE_PARM_DESC(lance_debug, "LANCE/PCnet debug level (0-7)");
 
-int init_module(void)
+int __init init_module(void)
 {
 	struct net_device *dev;
 	int this_dev, found = 0;
_
