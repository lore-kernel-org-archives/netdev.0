From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] fec: Remove unneeded asm header files
Date: Wed, 17 Apr 2013 23:18:17 -0300
Message-ID: <1366251498-11677-1-git-send-email-festevam@gmail.com>
Cc: gerg@uclinux.org, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:59328 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964828Ab3DRCTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 22:19:07 -0400
Received: by mail-yh0-f52.google.com with SMTP id q3so382596yhf.11
        for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 19:19:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

There is nothing in the driver that requires asm header files.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
Greg,

I built this for ARM and x86 (tweaking Kconfig), but I don't have a m68k 
toolchain installed here to test it.

Please build it for m68k if you have a chance. Thanks

 drivers/net/ethernet/freescale/fec_main.c |    7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 719177b..22c0feb 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -50,13 +50,6 @@
 #include <linux/pinctrl/consumer.h>
 #include <linux/regulator/consumer.h>
 
-#include <asm/cacheflush.h>
-
-#ifndef CONFIG_ARM
-#include <asm/coldfire.h>
-#include <asm/mcfsim.h>
-#endif
-
 #include "fec.h"
 
 #if defined(CONFIG_ARM)
-- 
1.7.9.5
