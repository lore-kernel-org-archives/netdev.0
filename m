From: akpm@osdl.org
Subject: [patch 34/41] build fixes: smc91x
Date: Mon, 14 Aug 2006 23:00:22 -0700
Message-ID: <200608150600.k7F60MCk012724@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, david-b@pacbell.net,
	dbrownell@users.sourceforge.net, nico@cam.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:44178 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965142AbWHOGAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:43 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Brownell <david-b@pacbell.net>

Unclear how these bugs arrived, presumably from incorrect cleanup of
the 16-bit-only paths, but smc91x wouldn't build for OMAP.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
Cc: Nicolas Pitre <nico@cam.org>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/smc91x.h |    6 ------
 1 file changed, 6 deletions(-)

diff -puN drivers/net/smc91x.h~build-fixes-smc91x drivers/net/smc91x.h
--- a/drivers/net/smc91x.h~build-fixes-smc91x
+++ a/drivers/net/smc91x.h
@@ -184,16 +184,10 @@ SMC_outw(u16 val, void __iomem *ioaddr, 
 #define SMC_IO_SHIFT		0
 #define SMC_NOWAIT		1
 
-#define SMC_inb(a, r)		readb((a) + (r))
-#define SMC_outb(v, a, r)	writeb(v, (a) + (r))
 #define SMC_inw(a, r)		readw((a) + (r))
 #define SMC_outw(v, a, r)	writew(v, (a) + (r))
 #define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
-#define SMC_inl(a, r)		readl((a) + (r))
-#define SMC_outl(v, a, r)	writel(v, (a) + (r))
-#define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
-#define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
 
 #include <asm/mach-types.h>
 #include <asm/arch/cpu.h>
_
