From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] ipmr: Replace comma with semicolon
Date: Fri, 30 May 2014 21:10:48 +0530
Message-ID: <20140530154048.GA3949@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces a comma between expression statements by a semicolon.

A simplified version of the semantic patch that performs this
transformation is as follows:

// <smpl>
@r@
expression e1,e2,e;
type T;
identifier i;
@@

 e1
-,
+;
 e2;
// </smpl>

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
---
 net/ipv4/ipmr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index d84dc8d..2bc9cc4 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -484,7 +484,7 @@ static void reg_vif_setup(struct net_device *dev)
 	dev->type		= ARPHRD_PIMREG;
 	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr) - 8;
 	dev->flags		= IFF_NOARP;
-	dev->netdev_ops		= &reg_vif_netdev_ops,
+	dev->netdev_ops		= &reg_vif_netdev_ops;
 	dev->destructor		= free_netdev;
 	dev->features		|= NETIF_F_NETNS_LOCAL;
 }
-- 
1.9.1
