From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 RFC 03/13] ipvlan: Stop advertising NETIF_F_UFO support.
Date: Fri, 07 Jul 2017 10:43:50 +0100 (WEST)
Message-ID: <20170707.104350.6947290116397787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemdebruijn.kernel@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49792 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751091AbdGGJnw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 05:43:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is going away.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ipvlan/ipvlan_main.c | 2 +-
 drivers/net/ipvlan/ipvtap.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index f37e3c1..fdde207 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -169,7 +169,7 @@ static void ipvlan_port_destroy(struct net_device *dev)
 
 #define IPVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
-	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
+	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_GSO_ROBUST | \
 	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO | NETIF_F_RXCSUM | \
 	 NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_HW_VLAN_STAG_FILTER)
 
diff --git a/drivers/net/ipvlan/ipvtap.c b/drivers/net/ipvlan/ipvtap.c
index 22f133e..5dea206 100644
--- a/drivers/net/ipvlan/ipvtap.c
+++ b/drivers/net/ipvlan/ipvtap.c
@@ -24,7 +24,7 @@
 #include <linux/virtio_net.h>
 
 #define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
-		      NETIF_F_TSO6 | NETIF_F_UFO)
+		      NETIF_F_TSO6)
 
 static dev_t ipvtap_major;
 static struct cdev ipvtap_cdev;
-- 
2.9.4
