From: Timur Tabi <timur@freescale.com>
Subject: [PATCH 2/7] net/fsl_pq_mdio: trim #include statements
Date: Wed, 29 Aug 2012 13:07:58 -0500
Message-ID: <1346263683-3664-2-git-send-email-timur@freescale.com>
References: <1346263683-3664-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:39657
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754306Ab2H2SIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 14:08:12 -0400
In-Reply-To: <1346263683-3664-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove several unnecessary #include statements.

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index bc19fe0..edaa25e 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -19,30 +19,18 @@
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/errno.h>
-#include <linux/unistd.h>
 #include <linux/slab.h>
-#include <linux/interrupt.h>
 #include <linux/init.h>
 #include <linux/delay.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/skbuff.h>
-#include <linux/spinlock.h>
-#include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/platform_device.h>
-#include <linux/crc32.h>
 #include <linux/mii.h>
-#include <linux/phy.h>
-#include <linux/of.h>
 #include <linux/of_address.h>
 #include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 
 #include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/uaccess.h>
-#include <asm/ucc.h>
+#include <asm/ucc.h>	/* for ucc_set_qe_mux_mii_mng() */
 
 #include "gianfar.h"
 
-- 
1.7.3.4
