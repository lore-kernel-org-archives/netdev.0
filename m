From: janitor@sternwelten.at
Subject: [patch 1/1]  remove old ifdefs dmascc
Date: Wed, 01 Sep 2004 22:49:15 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C2c2d-00077g-Sz@sputnik>
Cc: jgarzik@pobox.com, janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



 Patches to remove some old ifdefs.
 remove most of the #include <linux/version.h>
 kill compat cruft like #define ahd_pci_set_dma_mask pci_set_dma_mask

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.9-rc1-bk7-max/drivers/net/hamradio/dmascc.c |    1 -
 1 files changed, 1 deletion(-)

diff -puN drivers/net/hamradio/dmascc.c~remove-old-ifdefs-dmascc drivers/net/hamradio/dmascc.c
--- linux-2.6.9-rc1-bk7/drivers/net/hamradio/dmascc.c~remove-old-ifdefs-dmascc	2004-08-31 17:42:11.000000000 +0200
+++ linux-2.6.9-rc1-bk7-max/drivers/net/hamradio/dmascc.c	2004-08-31 17:42:11.000000000 +0200
@@ -37,7 +37,6 @@
 #include <linux/rtnetlink.h>
 #include <linux/sockios.h>
 #include <linux/workqueue.h>
-#include <linux/version.h>
 #include <asm/atomic.h>
 #include <asm/bitops.h>
 #include <asm/dma.h>

_
