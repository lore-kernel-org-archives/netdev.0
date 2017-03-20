From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/2] [net-next] net: dwc-xlgmac: include dcbnl.h
Date: Mon, 20 Mar 2017 09:51:12 +0100
Message-ID: <20170320085123.1032301-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jie Deng <jiedeng@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Without this header, we can run into a build error:

drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c: In function 'xlgmac_config_queue_mapping':
drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c:1548:36: error: 'IEEE_8021QAZ_MAX_TCS' undeclared (first use in this function)
  prio_queues = min_t(unsigned int, IEEE_8021QAZ_MAX_TCS,

Fixes: 65e0ace2c5cd ("net: dwc-xlgmac: Initial driver for DesignWare Enterprise Ethernet")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c
index 5cf3e90d4834..1e25a86f6a27 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-hw.c
@@ -22,6 +22,7 @@
 #include <linux/clk.h>
 #include <linux/bitrev.h>
 #include <linux/crc32.h>
+#include <linux/dcbnl.h>
 
 #include "dwc-xlgmac.h"
 #include "dwc-xlgmac-reg.h"
-- 
2.9.0
