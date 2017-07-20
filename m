From: Mark Brown <broonie@kernel.org>
Subject: [PATCH] net: ethernet: mediatek: Explicitly include linux/interrupt.h
Date: Thu, 20 Jul 2017 11:06:31 +0100
Message-ID: <20170720100631.16040-1-broonie@kernel.org>
Cc: netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        Mark Brown <broonie@kernel.org>
To: Felix Fietkau <nbd@openwrt.org>, John Crispin <blogic@openwrt.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:52926 "EHLO
        mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933887AbdGTKGs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 06:06:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mediatek ethernet driver uses interrupts but does not explicitly
include linux/interrupt.h, relying on implicit includes.  Fix this so we
don't get build breaks as happened for ARM in next-20170720.

Signed-off-by: Mark Brown <broonie@kernel.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 7e95cf547ff1..95881ef6ee24 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -22,6 +22,7 @@
 #include <linux/if_vlan.h>
 #include <linux/reset.h>
 #include <linux/tcp.h>
+#include <linux/interrupt.h>
 
 #include "mtk_eth_soc.h"
 
-- 
2.13.2
