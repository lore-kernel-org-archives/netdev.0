From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH] stmmac: fix sparse warnings
Date: Mon,  3 Nov 2014 19:28:53 +0200
Message-ID: <1415035734-24163-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32617 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752252AbaKCRdh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 12:33:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following sparse warnings.

drivers/net/ethernet/stmicro/stmmac/enh_desc.c:381:30: warning: symbol 'enh_desc_ops' was not declared. Should it be static?
drivers/net/ethernet/stmicro/stmmac/norm_desc.c:253:30: warning: symbol 'ndesc_ops' was not declared. Should it be static?
drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c:141:33: warning: symbol 'stmmac_ptp' was not declared. Should it be static?

There is no functional change.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c        | 2 ++
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c       | 2 ++
 drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c | 2 ++
 3 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index 1e2bcf5..ddd4272 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -23,8 +23,10 @@
 *******************************************************************************/
 
 #include <linux/stmmac.h>
+
 #include "common.h"
 #include "descs_com.h"
+#include "stmmac.h"
 
 static int enh_desc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 				  struct dma_desc *p, void __iomem *ioaddr)
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 35ad4f4..46b882c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -23,8 +23,10 @@
 *******************************************************************************/
 
 #include <linux/stmmac.h>
+
 #include "common.h"
 #include "descs_com.h"
+#include "stmmac.h"
 
 static int ndesc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 			       struct dma_desc *p, void __iomem *ioaddr)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
index 76ad214..88e0da3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
@@ -25,8 +25,10 @@
 
 #include <linux/io.h>
 #include <linux/delay.h>
+
 #include "common.h"
 #include "stmmac_ptp.h"
+#include "stmmac.h"
 
 static void stmmac_config_hw_tstamping(void __iomem *ioaddr, u32 data)
 {
-- 
2.1.1
