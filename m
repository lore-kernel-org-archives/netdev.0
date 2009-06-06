From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next 3/4] virtio_net: Allow UFO feature to be set on
 virtio_net device.
Date: Fri, 05 Jun 2009 17:16:34 -0700
Message-ID: <1244247394.1526.172.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, kvm@vger.kernel.org,
	herbert.xu@redhat.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:47134 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752832AbZFFAQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2009 20:16:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow UFO feature to be set on virtio_net device.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---


 drivers/net/virtio_net.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0c9ca67..d24ede0 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -773,6 +773,7 @@ static struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
 	.set_tso = ethtool_op_set_tso,
+	.set_ufo = ethtool_op_set_ufo,
 	.get_link = ethtool_op_get_link,
 };
 
@@ -1013,7 +1014,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
-	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
+	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
 	VIRTIO_F_NOTIFY_ON_EMPTY,


