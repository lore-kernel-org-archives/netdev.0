From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6 1/2] virtio-net: Allow UFO feature to be set
 and advertised.
Date: Tue, 14 Jul 2009 17:21:02 -0700
Message-ID: <1247617262.4998.76.camel@IBM-19B5263ED41-009047018100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Rusty Russell <rusty@rustcorp.com.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:41358 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755965AbZGOAVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2009 20:21:06 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e9.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6F08dAO019057
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 20:08:39 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n6F0L5Pu247176
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 20:21:05 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6F0IVTq028112
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 20:18:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net-next-2.6 1/2] virtio-net: Allow UFO feature to be set

- Allow setting UFO on virtio-net and advertise to host.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---------------------------------------------------------
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 2a6e81d..a6f903f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -774,6 +774,7 @@ static struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
 	.set_tso = ethtool_op_set_tso,
+	.set_ufo = ethtool_op_set_ufo,
 	.get_link = ethtool_op_get_link,
 };
 
@@ -1005,7 +1006,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
-	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
+	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
 	VIRTIO_F_NOTIFY_ON_EMPTY,
> 

