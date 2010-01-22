From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netdev: remove certain HAVE_ macros
Date: Fri, 22 Jan 2010 22:13:10 +0200
Message-ID: <20100122201310.GA22342@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:33352 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221Ab0AVUNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 15:13:16 -0500
Received: by fxm20 with SMTP id 20so1733913fxm.21
        for <netdev@vger.kernel.org>; Fri, 22 Jan 2010 12:13:14 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After netdev_ops compat code HAVE_* macros aren't needed, in fact
they _will_ result in compile breakage for out of tree drivers.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/netdevice.h |   10 ----------
 1 file changed, 10 deletions(-)

--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -621,30 +621,21 @@ struct net_device_ops {
 						   struct net_device *dev);
 	u16			(*ndo_select_queue)(struct net_device *dev,
 						    struct sk_buff *skb);
-#define HAVE_CHANGE_RX_FLAGS
 	void			(*ndo_change_rx_flags)(struct net_device *dev,
 						       int flags);
-#define HAVE_SET_RX_MODE
 	void			(*ndo_set_rx_mode)(struct net_device *dev);
-#define HAVE_MULTICAST
 	void			(*ndo_set_multicast_list)(struct net_device *dev);
-#define HAVE_SET_MAC_ADDR
 	int			(*ndo_set_mac_address)(struct net_device *dev,
 						       void *addr);
-#define HAVE_VALIDATE_ADDR
 	int			(*ndo_validate_addr)(struct net_device *dev);
-#define HAVE_PRIVATE_IOCTL
 	int			(*ndo_do_ioctl)(struct net_device *dev,
 					        struct ifreq *ifr, int cmd);
-#define HAVE_SET_CONFIG
 	int			(*ndo_set_config)(struct net_device *dev,
 					          struct ifmap *map);
-#define HAVE_CHANGE_MTU
 	int			(*ndo_change_mtu)(struct net_device *dev,
 						  int new_mtu);
 	int			(*ndo_neigh_setup)(struct net_device *dev,
 						   struct neigh_parms *);
-#define HAVE_TX_TIMEOUT
 	void			(*ndo_tx_timeout) (struct net_device *dev);
 
 	struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
@@ -656,7 +647,6 @@ struct net_device_ops {
 	void			(*ndo_vlan_rx_kill_vid)(struct net_device *dev,
 						        unsigned short vid);
 #ifdef CONFIG_NET_POLL_CONTROLLER
-#define HAVE_NETDEV_POLL
 	void                    (*ndo_poll_controller)(struct net_device *dev);
 #endif
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
