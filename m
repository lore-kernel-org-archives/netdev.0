From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/3] net: remove dsa.h include from linux/netdevice.h
Date: Tue,  6 Oct 2015 17:54:27 -0400
Message-ID: <1444168467-10293-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1444168467-10293-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444168467-10293-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Forward declare struct dsa_switch_tree in netdevice.h instead of
including the dsa.h header.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/linux/netdevice.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1986a22..4618b1d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -38,13 +38,12 @@
 #include <linux/dmaengine.h>
 #include <linux/workqueue.h>
 #include <linux/dynamic_queue_limits.h>
 
 #include <linux/ethtool.h>
 #include <net/net_namespace.h>
-#include <net/dsa.h>
 #ifdef CONFIG_DCB
 #include <net/dcbnl.h>
 #endif
 #include <net/netprio_cgroup.h>
 
 #include <linux/netdev_features.h>
@@ -57,12 +56,14 @@ struct device;
 struct phy_device;
 /* 802.11 specific */
 struct wireless_dev;
 /* 802.15.4 specific */
 struct wpan_dev;
 struct mpls_dev;
+/* DSA specific */
+struct dsa_switch_tree;
 
 void netdev_set_default_ethtool_ops(struct net_device *dev,
 				    const struct ethtool_ops *ops);
 
 /* Backlog congestion levels */
 #define NET_RX_SUCCESS		0	/* keep 'em coming, baby */
-- 
2.6.0
