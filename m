From: Yann Droneaud <ydroneaud@opteya.com>
Subject: [PATCH] 6lowpan: add a license to 6lowpan_iphc module
Date: Wed, 22 Jan 2014 20:25:24 +0100
Message-ID: <1390418724-9804-1-git-send-email-ydroneaud@opteya.com>
Cc: Yann Droneaud <ydroneaud@opteya.com>,
	linux-zigbee-devel@lists.sourceforge.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jukka Rissanen <jukka.rissanen@linux.intel.com>,
	Alexander Aring <alex.aring@gmail.com>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit 8df8c56a5abc, 6lowpan_iphc is a module of its own.

Unfortunately, it lacks some infrastructure to behave like a
good kernel citizen:

  kernel: 6lowpan_iphc: module license 'unspecified' taints kernel.
  kernel: Disabling lock debugging due to kernel taint

This patch adds the basic MODULE_LICENSE(); with GPL license:
the code was copied from net/ieee802154/6lowpan.c which is GPL
and the module exports symbol with EXPORT_SYMBOL_GPL();.

Cc: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Cc: Alexander Aring <alex.aring@gmail.com>
Cc: Marcel Holtmann <marcel@holtmann.org>
Signed-off-by: Yann Droneaud <ydroneaud@opteya.com>
---
 net/ieee802154/6lowpan_iphc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ieee802154/6lowpan_iphc.c b/net/ieee802154/6lowpan_iphc.c
index e14fe8b2c054..860aa2d445ba 100644
--- a/net/ieee802154/6lowpan_iphc.c
+++ b/net/ieee802154/6lowpan_iphc.c
@@ -52,6 +52,7 @@
 
 #include <linux/bitops.h>
 #include <linux/if_arp.h>
+#include <linux/module.h>
 #include <linux/netdevice.h>
 #include <net/ipv6.h>
 #include <net/af_ieee802154.h>
@@ -797,3 +798,5 @@ int lowpan_header_compress(struct sk_buff *skb, struct net_device *dev,
 	return 0;
 }
 EXPORT_SYMBOL_GPL(lowpan_header_compress);
+
+MODULE_LICENSE("GPL");
-- 
1.8.4.2
