From: Joe Perches <joe@perches.com>
Subject: [PATCH 04/10] amd/7990: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 15:11:31 -0700
Message-ID: <65ef2eba58fddc268ba0afb4de7757f073d3bb49.1379974101.git.joe@perches.com>
References: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/amd/7990.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/amd/7990.h b/drivers/net/ethernet/amd/7990.h
index 0a5837b..ae33a99 100644
--- a/drivers/net/ethernet/amd/7990.h
+++ b/drivers/net/ethernet/amd/7990.h
@@ -242,14 +242,13 @@ struct lance_private
 #define LANCE_ADDR(x) ((int)(x) & ~0xff000000)
 
 /* Now the prototypes we export */
-extern int lance_open(struct net_device *dev);
-extern int lance_close (struct net_device *dev);
-extern int lance_start_xmit (struct sk_buff *skb, struct net_device *dev);
-extern void lance_set_multicast (struct net_device *dev);
-extern void lance_tx_timeout(struct net_device *dev);
+int lance_open(struct net_device *dev);
+int lance_close(struct net_device *dev);
+int lance_start_xmit(struct sk_buff *skb, struct net_device *dev);
+void lance_set_multicast(struct net_device *dev);
+void lance_tx_timeout(struct net_device *dev);
 #ifdef CONFIG_NET_POLL_CONTROLLER
-extern void lance_poll(struct net_device *dev);
+void lance_poll(struct net_device *dev);
 #endif
 
 #endif /* ndef _7990_H */
-- 
1.8.1.2.459.gbcd45b4.dirty
