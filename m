From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 7/8] virtio: make some structures const
Date: Mon, 29 Oct 2012 17:57:38 -0700
Message-ID: <20121030005835.810565784@vyatta.com>
References: <20121030005731.843020405@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:35111 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758902Ab2J3BGP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 21:06:15 -0400
Content-Disposition: inline; filename=virtio-const.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/virtio_net.c	2012-10-26 12:27:23.911918635 -0700
+++ b/drivers/net/virtio_net.c	2012-10-26 12:52:28.632806729 -0700
@@ -1274,12 +1274,12 @@ static int virtnet_restore(struct virtio
 }
 #endif
 
-static struct virtio_device_id id_table[] = {
+static const struct virtio_device_id id_table[] = {
 	{ VIRTIO_ID_NET, VIRTIO_DEV_ANY_ID },
 	{ 0 },
 };
 
-static unsigned int features[] = {
+static const unsigned int features[] = {
 	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GUEST_CSUM,
 	VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
@@ -1290,7 +1290,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GUEST_ANNOUNCE,
 };
 
-static struct virtio_driver virtio_net_driver = {
+static struct virtio_driver virtio_net_driver __read_mostly = {
 	.feature_table = features,
 	.feature_table_size = ARRAY_SIZE(features),
 	.driver.name =	KBUILD_MODNAME,
