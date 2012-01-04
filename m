From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 5/6] r6040: use __aligned(size)
Date: Wed,  4 Jan 2012 19:59:37 +0100
Message-ID: <1325703578-17275-6-git-send-email-florian@openwrt.org>
References: <1325703578-17275-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:60771 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756779Ab2ADS7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 13:59:53 -0500
In-Reply-To: <1325703578-17275-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

instead of __attribute__((__aligned(size)__))

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index e9054a9..b8dc727 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -173,7 +173,7 @@ struct r6040_descriptor {
 	struct r6040_descriptor *vndescp;	/* 14-17 */
 	struct sk_buff *skb_ptr;	/* 18-1B */
 	u32	rev2;			/* 1C-1F */
-} __attribute__((aligned(32)));
+} __aligned(32);
 
 struct r6040_private {
 	spinlock_t lock;		/* driver lock */
-- 
1.7.5.4
