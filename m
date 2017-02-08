From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 05/16] net: stmmac: remplace asm/io.h by linux/io.h
Date: Wed,  8 Feb 2017 09:31:10 +0100
Message-ID: <20170208083121.27949-6-clabbe.montjoie@gmail.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix the checkpatch warning about asm/io.h.
Sorting all includes in the process.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 738d5c7..3fdc6ec 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -20,13 +20,13 @@
   Maintainer: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
+#include <linux/io.h>
 #include <linux/mii.h>
-#include <linux/phy.h>
-#include <linux/slab.h>
 #include <linux/of.h>
 #include <linux/of_gpio.h>
 #include <linux/of_mdio.h>
-#include <asm/io.h>
+#include <linux/phy.h>
+#include <linux/slab.h>
 
 #include "stmmac.h"
 
-- 
2.10.2
