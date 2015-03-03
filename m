From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 10/14] bluetooth: Use eth_<foo>_addr instead of memset
Date: Mon,  2 Mar 2015 19:54:55 -0800
Message-ID: <3e4a2efa6cbc9bea479bd3d8460ea56dda128faf.1425354528.git.joe@perches.com>
References: <cover.1425354527.git.joe@perches.com>
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1425354527.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the built-in function instead of memset.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/bluetooth/bnep/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index 4b488ec..6ceb5d3 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -218,7 +218,7 @@ static const struct net_device_ops bnep_netdev_ops = {
 void bnep_net_setup(struct net_device *dev)
 {
 
-	memset(dev->broadcast, 0xff, ETH_ALEN);
+	eth_broadcast_addr(dev->broadcast);
 	dev->addr_len = ETH_ALEN;
 
 	ether_setup(dev);
-- 
2.1.2
