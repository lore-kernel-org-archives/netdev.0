From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH 1/3] virtio: Fix typo in virtio_net_hdr comments
Date: Tue, 27 May 2008 12:20:45 +0100
Message-ID: <1211887247-31979-2-git-send-email-markmc@redhat.com>
References: <1211887247-31979-1-git-send-email-markmc@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Mark McLoughlin <markmc@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail13.svc.cra.dublin.eircom.net ([159.134.118.29]:42384 "HELO
	mail13.svc.cra.dublin.eircom.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756624AbYE0L1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 07:27:30 -0400
In-Reply-To: <1211887247-31979-1-git-send-email-markmc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 include/linux/virtio_net.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
-- 
1.5.4.1

