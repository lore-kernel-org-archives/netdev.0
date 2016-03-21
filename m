From: Luis de Bethencourt <luisbg@osg.samsung.com>
Subject: [PATCH v2] net: add missing descriptions in net_device_priv_flags
Date: Mon, 21 Mar 2016 20:58:28 +0000
Message-ID: <1458593908-4295-1-git-send-email-luisbg@osg.samsung.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	benjamin.poirier@gmail.com,
	Luis de Bethencourt <luisbg@osg.samsung.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The flags IFF_XMIT_DST_RELEASE_PERM, IFF_IPVLAN_MASTER and
IFF_IPVLAN_SLAVE are missing descriptions for the Documentation. Adding
them.

Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
Suggested-by: Benjamin Poirier <benjamin.poirier@gmail.com>
---
Hi,

Changing the description of IFF_XMIT_DST_RELEASE_PERM as suggested by Benjamin
and adding him to the Suggested-by for it.
https://lkml.org/lkml/2016/3/21/693

Thanks,
Luis

 include/linux/netdevice.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index be693b3..bcca180 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1320,6 +1320,10 @@ struct net_device_ops {
  * @IFF_LIVE_ADDR_CHANGE: device supports hardware address
  *	change when it's running
  * @IFF_MACVLAN: Macvlan device
+ * @IFF_XMIT_DST_RELEASE_PERM: IFF_XMIT_DST_RELEASE not taking into account
+ *	underlying stacked devices
+ * @IFF_IPVLAN_MASTER: IPvlan master device
+ * @IFF_IPVLAN_SLAVE: IPvlan slave device
  * @IFF_L3MDEV_MASTER: device is an L3 master device
  * @IFF_NO_QUEUE: device can run without qdisc attached
  * @IFF_OPENVSWITCH: device is a Open vSwitch master
-- 
2.5.1
