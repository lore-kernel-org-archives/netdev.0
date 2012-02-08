From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 41/50] l2tp_eth: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:48 +0100
Message-ID: <1328735457-29986-42-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	James Chapman <jchapman@katalix.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 net/l2tp/l2tp_eth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index d2726a7..fa91e4e 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -64,7 +64,7 @@ static int l2tp_eth_dev_init(struct net_device *dev)
 	struct l2tp_eth *priv = netdev_priv(dev);
 
 	priv->dev = dev;
-	random_ether_addr(dev->dev_addr);
+	dev_hw_addr_random(dev, dev->dev_addr);
 	memset(&dev->broadcast[0], 0xff, 6);
 
 	return 0;
-- 
1.7.7.3
