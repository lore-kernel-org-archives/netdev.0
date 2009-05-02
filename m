From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH] virtio_net: Fix function name typo
Date: Fri, 01 May 2009 21:31:10 -0600
Message-ID: <20090502033028.7977.69014.stgit@debian.lart>
References: <20090501.153315.115088159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, netdev@vger.kernel.org
To: davem@davemloft.net, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:37976 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbZEBDfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 23:35:34 -0400
In-Reply-To: <20090501.153315.115088159.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 Applies against Message-ID: <20090502032646.7927.99584.stgit@debian.lart>

 drivers/net/virtio_net.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 23eb282..4d1d479 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -748,7 +748,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	kfree(buf);
 }
 
-static void virnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
+static void virtnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct scatterlist sg;
@@ -760,7 +760,7 @@ static void virnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
 		dev_warn(&dev->dev, "Failed to add VLAN ID %d.\n", vid);
 }
 
-static void virnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
+static void virtnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct scatterlist sg;
@@ -798,8 +798,8 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_set_mac_address = virtnet_set_mac_address,
 	.ndo_set_rx_mode     = virtnet_set_rx_mode,
 	.ndo_change_mtu	     = virtnet_change_mtu,
-	.ndo_vlan_rx_add_vid = virnet_vlan_rx_add_vid,
-	.ndo_vlan_rx_kill_vid = virnet_vlan_rx_kill_vid,
+	.ndo_vlan_rx_add_vid = virtnet_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid = virtnet_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
 #endif

