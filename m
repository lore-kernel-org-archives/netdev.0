From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 RFC 02/13] macb: Remove bogus reference to NETIF_F_UFO.
Date: Fri, 07 Jul 2017 10:43:42 +0100 (WEST)
Message-ID: <20170707.104342.393105911960085522.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemdebruijn.kernel@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751091AbdGGJno (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 05:43:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This driver doesn't actually support UFO explicitly yet
it advertises this in netdev->features.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/cadence/macb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb_main.c b/drivers/net/ethernet/cadence/macb_main.c
index e69ebdd..a02f916 100644
--- a/drivers/net/ethernet/cadence/macb_main.c
+++ b/drivers/net/ethernet/cadence/macb_main.c
@@ -68,7 +68,7 @@
 #define GEM_MAX_TX_LEN		((unsigned int)((1 << GEM_TX_FRMLEN_SIZE) - 1) & ~((unsigned int)(MACB_TX_LEN_ALIGN - 1)))
 
 #define GEM_MTU_MIN_SIZE	ETH_MIN_MTU
-#define MACB_NETIF_LSO		(NETIF_F_TSO | NETIF_F_UFO)
+#define MACB_NETIF_LSO		NETIF_F_TSO
 
 #define MACB_WOL_HAS_MAGIC_PACKET	(0x1 << 0)
 #define MACB_WOL_ENABLED		(0x1 << 1)
-- 
2.9.4
