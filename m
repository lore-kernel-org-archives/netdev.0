From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] virtio_net: Set VIRTIO_NET_F_GUEST_CSUM feature
Date: Tue, 8 Jul 2008 17:10:42 +1000
Message-ID: <200807081710.42530.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54706 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755469AbYGHHKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 03:10:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark McLoughlin <markmc@redhat.com>

We can handle receiving partial csums, so set the
appropriate feature bit.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -550,7 +550,8 @@ static struct virtio_device_id id_table[
 };
 
 static unsigned int features[] = {
-	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
+	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GUEST_CSUM,
+	VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_F_NOTIFY_ON_EMPTY,
 };
