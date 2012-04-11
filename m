From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/8] r6040: remove unused variable mcr1 from private structure
Date: Wed, 11 Apr 2012 19:18:37 +0200
Message-ID: <1334164723-9627-3-git-send-email-florian@openwrt.org>
References: <1334164723-9627-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:45793 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932399Ab2DKRUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 13:20:13 -0400
In-Reply-To: <1334164723-9627-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index c10b0b8..fa29596 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -187,7 +187,7 @@ struct r6040_private {
 	dma_addr_t rx_ring_dma;
 	dma_addr_t tx_ring_dma;
 	u16	tx_free_desc;
-	u16	mcr0, mcr1;
+	u16	mcr0;
 	struct net_device *dev;
 	struct mii_bus *mii_bus;
 	struct napi_struct napi;
-- 
1.7.5.4
