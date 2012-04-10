From: Michael Neuling <mikey@neuling.org>
Subject: [PATCH] gianfar: add missing include
Date: Tue, 10 Apr 2012 14:18:47 +1000
Message-ID: <25411.1334031527@neuling.org>
Mime-Version: 1.0
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

next-20120405 compiled with mpc85xx_defconfig gives the following:

  CC      drivers/net/ethernet/freescale/gianfar_ethtool.o
drivers/net/ethernet/freescale/gianfar_ethtool.c: In function 'gfar_get_ts_info':
drivers/net/ethernet/freescale/gianfar_ethtool.c:1751:4: error: 'SOF_TIMESTAMPING_RX_SOFTWARE' undeclared (first use in this function)
drivers/net/ethernet/freescale/gianfar_ethtool.c:1751:4: note: each undeclared identifier is reported only once for each function it appears in
drivers/net/ethernet/freescale/gianfar_ethtool.c:1752:4: error: 'SOF_TIMESTAMPING_SOFTWARE' undeclared (first use in this function)
drivers/net/ethernet/freescale/gianfar_ethtool.c:1757:3: error: 'SOF_TIMESTAMPING_TX_HARDWARE' undeclared (first use in this function)
drivers/net/ethernet/freescale/gianfar_ethtool.c:1758:3: error: 'SOF_TIMESTAMPING_RX_HARDWARE' undeclared (first use in this function)
drivers/net/ethernet/freescale/gianfar_ethtool.c:1759:3: error: 'SOF_TIMESTAMPING_RAW_HARDWARE' undeclared (first use in this function)
drivers/net/ethernet/freescale/gianfar_ethtool.c:1762:9: error: 'HWTSTAMP_TX_OFF' undeclared (first use in this function)
drivers/net/ethernet/freescale/gianfar_ethtool.c:1763:9: error: 'HWTSTAMP_TX_ON' undeclared (first use in this function)
drivers/net/ethernet/freescale/gianfar_ethtool.c:1765:9: error: 'HWTSTAMP_FILTER_NONE' undeclared (first use in this function)
drivers/net/ethernet/freescale/gianfar_ethtool.c:1766:9: error: 'HWTSTAMP_FILTER_ALL' undeclared (first use in this function)

This is because of a missing include file from:
  6663628 gianfar: Support the get_ts_info ethtool method.

Signed-off-by: Michael Neuling <mikey@neuling.org>
CC: Richard Cochran <richardcochran@gmail.com>
CC: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 27f49c7..3c34b32b 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -29,6 +29,7 @@
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/mm.h>
+#include <linux/net_tstamp.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
