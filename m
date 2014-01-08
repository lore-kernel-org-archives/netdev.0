From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net 2/2] net: remove the unused function netdev_add_tso_features()
Date: Wed, 8 Jan 2014 15:28:27 +0800
Message-ID: <52CCFE1B.7070201@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:48923 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754539AbaAHHav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 02:30:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function is only used for bonding and the bond has another
function bond_add_tso_features() to instead of it, so remove it.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 include/linux/netdevice.h | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 51c0fe2..183cd8e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2985,16 +2985,6 @@ static inline netdev_features_t netdev_get_wanted_features(
 netdev_features_t netdev_increment_features(netdev_features_t all,
 	netdev_features_t one, netdev_features_t mask);
 
-/* Allow TSO being used on stacked device :
- * Performing the GSO segmentation before last device
- * is a performance improvement.
- */
-static inline netdev_features_t netdev_add_tso_features(netdev_features_t features,
-							netdev_features_t mask)
-{
-	return netdev_increment_features(features, NETIF_F_ALL_TSO, mask);
-}
-
 int __netdev_update_features(struct net_device *dev);
 void netdev_update_features(struct net_device *dev);
 void netdev_change_features(struct net_device *dev);
-- 
1.8.0
