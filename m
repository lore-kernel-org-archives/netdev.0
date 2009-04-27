From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH] virtio_net: Fix function name typo
Date: Mon, 27 Apr 2009 09:55:38 -0600
Message-ID: <20090427155507.7895.79747.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, netdev@vger.kernel.org
To: davem@davemloft.net, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:44009 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754899AbZD0QCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 12:02:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 drivers/net/virtio_net.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index ed70df4..6cc5bcd 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -744,7 +744,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	kfree(buf);
 }
 
-static void virnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
+static void virtnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct scatterlist sg;
@@ -756,7 +756,7 @@ static void virnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
 		dev_warn(&dev->dev, "Failed to add VLAN ID %d.\n", vid);
 }
 
-static void virnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
+static void virtnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct scatterlist sg;
@@ -794,8 +794,8 @@ static const struct net_device_ops virtnet_netdev = {
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

