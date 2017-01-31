From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 05/17] net: stmmac: remplace asm/io.h by linux/io.h
Date: Tue, 31 Jan 2017 10:11:40 +0100
Message-ID: <20170131091152.13842-6-clabbe.montjoie@gmail.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:33178 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751104AbdAaJpg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 04:45:36 -0500
In-Reply-To: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
