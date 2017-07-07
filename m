From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 RFC 06/13] dummy: Remove references to NETIF_F_UFO.
Date: Fri, 07 Jul 2017 10:44:12 +0100 (WEST)
Message-ID: <20170707.104412.1351586048188074085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemdebruijn.kernel@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49810 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751862AbdGGJoO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 05:44:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is going away.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/dummy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index d0c165d..d0a1f9c 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -345,7 +345,7 @@ static void dummy_setup(struct net_device *dev)
 	dev->flags &= ~IFF_MULTICAST;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
 	dev->features	|= NETIF_F_SG | NETIF_F_FRAGLIST;
-	dev->features	|= NETIF_F_ALL_TSO | NETIF_F_UFO;
+	dev->features	|= NETIF_F_ALL_TSO;
 	dev->features	|= NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_LLTX;
 	dev->features	|= NETIF_F_GSO_ENCAP_ALL;
 	dev->hw_features |= dev->features;
-- 
2.9.4
