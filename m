From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH v2] fec: Remove unneeded asm header files
Date: Thu, 18 Apr 2013 09:54:39 -0300
Message-ID: <1366289682-3889-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <gerg@uclinux.org>, <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0184.outbound.messaging.microsoft.com ([213.199.154.184]:54656
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755066Ab3DRMy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 08:54:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is nothing in the driver that requires <asm/coldfire.h> and
<asm/mcfsim.h>.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
Changes since v1:
- Keep <asm/cacheflush.h> CONFIG_M532x needs it.

 drivers/net/ethernet/freescale/fec_main.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 719177b..94a4d83 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -52,11 +52,6 @@
 
 #include <asm/cacheflush.h>
 
-#ifndef CONFIG_ARM
-#include <asm/coldfire.h>
-#include <asm/mcfsim.h>
-#endif
-
 #include "fec.h"
 
 #if defined(CONFIG_ARM)
-- 
1.7.9.5
