From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 14/14] l2tp: Use eth_<foo>_addr instead of memset
Date: Mon,  2 Mar 2015 19:54:59 -0800
Message-ID: <8704e46e74af2664e88d79eb2257bc8f761faadd.1425354528.git.joe@perches.com>
References: <cover.1425354527.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1425354527.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the built-in function instead of memset.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/l2tp/l2tp_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 781b3a2..4b55287 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -74,7 +74,7 @@ static int l2tp_eth_dev_init(struct net_device *dev)
 
 	priv->dev = dev;
 	eth_hw_addr_random(dev);
-	memset(&dev->broadcast[0], 0xff, 6);
+	eth_broadcast_addr(dev->broadcast);
 	dev->qdisc_tx_busylock = &l2tp_eth_tx_busylock;
 	return 0;
 }
-- 
2.1.2
