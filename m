From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] drivers/net/dnet.c needs <linux/io.h>
Date: Tue, 24 Mar 2009 20:43:25 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0903242042060.19647@anakin>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Ilya Yanok <yanok@emcraft.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762573AbZCXToL@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On m68k:
| drivers/net/dnet.c: In function 'dnet_readw_mac':
| drivers/net/dnet.c:36: error: implicit declaration of function 'writel'
| drivers/net/dnet.c:43: error: implicit declaration of function 'readl'
| drivers/net/dnet.c: In function 'dnet_probe':
| drivers/net/dnet.c:873: error: implicit declaration of function 'ioremap'
| drivers/net/dnet.c:873: warning: assignment makes pointer from integer without a cast
| drivers/net/dnet.c:939: error: implicit declaration of function 'iounmap'

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/dnet.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index 1b40632..edf23c9 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -9,6 +9,7 @@
  * published by the Free Software Foundation.
  */
 #include <linux/version.h>
+#include <linux/io.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/kernel.h>
-- 
1.6.2

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
