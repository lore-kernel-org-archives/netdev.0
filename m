From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] netdevice: Neaten includes and forward declarations
Date: Sun, 16 Nov 2014 14:21:31 -0800
Message-ID: <1416176491.24600.3.camel@perches.com>
References: <1416031715-32498-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5467C3BA.6090003@gmail.com> <1416091109.5912.32.camel@perches.com>
	 <20141116.154923.1364136096942964102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0032.hostedemail.com ([216.40.44.32]:46063 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751416AbaKPWVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 17:21:34 -0500
In-Reply-To: <20141116.154923.1364136096942964102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the appropriate #include path for neighbour.h and
add device.h which was indirectly #included by dmaengine.h

Remove unnecessary forward declaration of struct device;

Add comments for other forward struct declarations.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/netdevice.h | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fa6bd7d..33ce566 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -36,6 +36,7 @@
 
 #include <linux/percpu.h>
 #include <linux/rculist.h>
+#include <linux/device.h>
 #include <linux/dmaengine.h>
 #include <linux/workqueue.h>
 #include <linux/dynamic_queue_limits.h>
@@ -49,16 +50,15 @@
 #include <net/netprio_cgroup.h>
 
 #include <linux/netdev_features.h>
-#include <linux/neighbour.h>
+
+#include <uapi/linux/neighbour.h>
 #include <uapi/linux/netdevice.h>
 
-struct netpoll_info;
-struct device;
-struct phy_device;
-/* 802.11 specific */
-struct wireless_dev;
-/* 802.15.4 specific */
-struct wpan_dev;
+/* forward struct type declarations */
+struct netpoll_info;		/* for net_device_ops */
+struct phy_device;		/* for net_device */
+struct wireless_dev;		/* for net_device: 802.11 specific */
+struct wpan_dev;		/* for net_device: 802.15.4 specific */
 
 void netdev_set_default_ethtool_ops(struct net_device *dev,
 				    const struct ethtool_ops *ops);
