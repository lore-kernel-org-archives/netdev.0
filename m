From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH]spider_net:remove '&' in the init of function pointers
Date: Fri, 20 Mar 2009 16:18:37 +0800
Message-ID: <49C3515D.7090703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jens@de.ibm.com, kou.ishizaki@toshiba.co.jp,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58041 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752921AbZCTITc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 04:19:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not need '&' in the init of function pointers.

Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com>

---
 drivers/net/spider_net.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 88d2c67..247fe9b 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -2268,20 +2268,20 @@ spider_net_tx_timeout(struct net_device *netdev)
 static void
 spider_net_setup_netdev_ops(struct net_device *netdev)
 {
-	netdev->open = &spider_net_open;
-	netdev->stop = &spider_net_stop;
-	netdev->hard_start_xmit = &spider_net_xmit;
-	netdev->set_multicast_list = &spider_net_set_multi;
-	netdev->set_mac_address = &spider_net_set_mac;
-	netdev->change_mtu = &spider_net_change_mtu;
-	netdev->do_ioctl = &spider_net_do_ioctl;
+	netdev->open = spider_net_open;
+	netdev->stop = spider_net_stop;
+	netdev->hard_start_xmit = spider_net_xmit;
+	netdev->set_multicast_list = spider_net_set_multi;
+	netdev->set_mac_address = spider_net_set_mac;
+	netdev->change_mtu = spider_net_change_mtu;
+	netdev->do_ioctl = spider_net_do_ioctl;
 	/* tx watchdog */
-	netdev->tx_timeout = &spider_net_tx_timeout;
+	netdev->tx_timeout = spider_net_tx_timeout;
 	netdev->watchdog_timeo = SPIDER_NET_WATCHDOG_TIMEOUT;
 	/* HW VLAN */
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	/* poll controller */
-	netdev->poll_controller = &spider_net_poll_controller;
+	netdev->poll_controller = spider_net_poll_controller;
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 	/* ethtool ops */
 	netdev->ethtool_ops = &spider_net_ethtool_ops;
-- 
1.6.0.3

-- 
Regards
Yang Hongyang
