From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [patch 2/3] netdev: i82596 Ethernet needs <asm/cacheflush.h>
Date: Fri, 20 Jul 2007 18:40:45 +0200
Message-ID: <20070720164323.848002388@mail.of.borg>
References: <20070720164043.523003359@mail.of.borg>
Cc: linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S938435AbXGTQso@vger.kernel.org>
Content-Disposition: inline; filename=m68k-82596-needs-asm-cacheflush.diff
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev: i82596 Ethernet needs <asm/cacheflush.h> on m68k

drivers/net/82596.c: In function 'init_rx_bufs':
drivers/net/82596.c:552: error: implicit declaration of function 'cache_clear'
drivers/net/82596.c: In function 'i596_start_xmit':
drivers/net/82596.c:1104: error: implicit declaration of function 'cache_push'

The driver still compiles on ia32 (CONFIG_APRICOT=y)

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/82596.c |    1 +
 1 file changed, 1 insertion(+)

--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -57,6 +57,7 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/pgtable.h>
+#include <asm/cacheflush.h>
 
 static char version[] __initdata =
 	"82596.c $Revision: 1.5 $\n";

-- 
Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
