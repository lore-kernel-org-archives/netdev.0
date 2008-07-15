From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 1/5] virtio_net: Set VIRTIO_NET_F_GUEST_CSUM feature
Date: Tue, 15 Jul 2008 13:35:48 +1000
Message-ID: <200807151335.48600.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38467 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753296AbYGODf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 23:35:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(I know you already have this, but included for completeness)

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
