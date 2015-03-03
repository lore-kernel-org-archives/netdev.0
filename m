From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 07/14] 8021q: Use eth_<foo>_addr instead of memset
Date: Mon,  2 Mar 2015 19:54:52 -0800
Message-ID: <86b4dbff62adb59123102f38efd3194da9692218.1425354528.git.joe@perches.com>
References: <cover.1425354527.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1425354527.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the built-in function instead of memset.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/8021q/vlan_dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1dcfec8..f196552 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -792,5 +792,5 @@ void vlan_setup(struct net_device *dev)
 	dev->destructor		= vlan_dev_free;
 	dev->ethtool_ops	= &vlan_ethtool_ops;
 
-	memset(dev->broadcast, 0, ETH_ALEN);
+	eth_zero_addr(dev->broadcast);
 }
-- 
2.1.2
