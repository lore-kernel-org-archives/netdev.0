From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] net: fec: Add a fec_enet_clear_ethtool_stats() stub for CONFIG_M5272
Date: Fri,  9 Jun 2017 22:37:22 -0300
Message-ID: <1497058642-31542-1-git-send-email-festevam@gmail.com>
Cc: fugang.duan@nxp.com, andrew@lunn.ch, cphealy@gmail.com,
        netdev@vger.kernel.org, paul.gortmaker@windriver.com,
        Fabio Estevam <fabio.estevam@nxp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35246 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751685AbdFJBhj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 21:37:39 -0400
Received: by mail-qt0-f193.google.com with SMTP id x58so18538270qtc.2
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 18:37:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@nxp.com>

Commit 2b30842b23b9 ("net: fec: Clear and enable MIB counters on imx51")
introduced fec_enet_clear_ethtool_stats(), but missed to add a stub
for the CONFIG_M5272=y case, causing build failure for the
m5272c3_defconfig.

Add the missing empty stub to fix the build failure.

Reported-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 297fd19..a6e323f 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2379,6 +2379,10 @@ static void fec_enet_clear_ethtool_stats(struct net_device *dev)
 static inline void fec_enet_update_ethtool_stats(struct net_device *dev)
 {
 }
+
+static inline void fec_enet_clear_ethtool_stats(struct net_device *dev)
+{
+}
 #endif /* !defined(CONFIG_M5272) */
 
 /* ITR clock source is enet system clock (clk_ahb).
-- 
2.7.4
