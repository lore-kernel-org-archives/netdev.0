From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/4] virtio: Fix typo in virtio_net_hdr comments
Date: Sun, 8 Jun 2008 20:49:59 +1000
Message-ID: <200806082050.00149.rusty@rustcorp.com.au>
References: <200806082049.00641.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Mark McLoughlin <markmc@redhat.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33210 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756185AbYFHKuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2008 06:50:14 -0400
In-Reply-To: <200806082049.00641.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark McLoughlin <markmc@redhat.com>

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 include/linux/virtio_net.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 9405aa6..38c0571 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -38,7 +38,7 @@ struct virtio_net_hdr
 #define VIRTIO_NET_HDR_GSO_ECN		0x80	// TCP has ECN set
 	__u8 gso_type;
 	__u16 hdr_len;		/* Ethernet + IP + tcp/udp hdrs */
-	__u16 gso_size;		/* Bytes to append to gso_hdr_len per frame */
+	__u16 gso_size;		/* Bytes to append to hdr_len per frame */
 	__u16 csum_start;	/* Position to start checksumming from */
 	__u16 csum_offset;	/* Offset after that to place checksum */
 };
