From: Lars Persson <lars.persson@axis.com>
Subject: [PATCH net 4/5] dwc_eth_qos: use DWCEQOS_MSG_DEFAULT
Date: Mon, 29 Feb 2016 16:22:33 +0100
Message-ID: <4f7ef5d73ce6c4718527c60ce2ac32f17bc2f55d.1456756740.git.larper@axis.com>
References: <cover.1456756740.git.larper@axis.com>
Cc: linux-kernel@vger.kernel.org, Rabin Vincent <rabinv@axis.com>,
	Lars Persson <larper@axis.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1456756740.git.larper@axis.com>
In-Reply-To: <cover.1456756740.git.larper@axis.com>
References: <cover.1456756740.git.larper@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rabin Vincent <rabinv@axis.com>

Since debug is hardcoded to 3, the defaults in the DWCEQOS_MSG_DEFAULT
macro are never used, which does not seem to be the intended behaviour
here.  Set debug to -1 like other drivers so that DWCEQOS_MSG_DEFAULT is
actually used by default.

Signed-off-by: Rabin Vincent <rabinv@axis.com>
Signed-off-by: Lars Persson <larper@axis.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 3ca2d5c..6897c1d 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -426,7 +426,7 @@
 #define DWC_MMC_RXOCTETCOUNT_GB          0x0784
 #define DWC_MMC_RXPACKETCOUNT_GB         0x0780
 
-static int debug = 3;
+static int debug = -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "DWC_eth_qos debug level (0=none,...,16=all)");
 
-- 
2.1.4
