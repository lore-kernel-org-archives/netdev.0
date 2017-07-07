From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 RFC 04/13] macvlan/macvtap: Remove NETIF_F_UFO
 advertisement.
Date: Fri, 07 Jul 2017 10:43:58 +0100 (WEST)
Message-ID: <20170707.104358.261784804607050237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemdebruijn.kernel@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49796 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751862AbdGGJoB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 05:44:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is going away.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/macvlan.c | 2 +-
 drivers/net/macvtap.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 0f581ee..ca35c6b 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -841,7 +841,7 @@ static struct lock_class_key macvlan_netdev_addr_lock_key;
 
 #define MACVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
-	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_LRO | \
+	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_LRO | \
 	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO | NETIF_F_RXCSUM | \
 	 NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_HW_VLAN_STAG_FILTER)
 
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 91e7b19b..c2d0ea2 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -49,7 +49,7 @@ static struct class macvtap_class = {
 static struct cdev macvtap_cdev;
 
 #define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
-		      NETIF_F_TSO6 | NETIF_F_UFO)
+		      NETIF_F_TSO6)
 
 static void macvtap_count_tx_dropped(struct tap_dev *tap)
 {
-- 
2.9.4
