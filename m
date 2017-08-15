From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/4] virtio: put paren around sizeof
Date: Tue, 15 Aug 2017 10:29:17 -0700
Message-ID: <20170815172919.26153-3-sthemmin@microsoft.com>
References: <20170815172919.26153-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: mlindner@marvell.com, stephen@networkplumber.org, mst@redhat.com,
        jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33289 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753575AbdHOR3b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 13:29:31 -0400
Received: by mail-pg0-f50.google.com with SMTP id u5so9574501pgn.0
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 10:29:31 -0700 (PDT)
In-Reply-To: <20170815172919.26153-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel coding style is to put paren around operand of sizeof.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/virtio_net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index a3f3c66b4530..4302f313d9a7 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -319,7 +319,7 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 
 	hdr_len = vi->hdr_len;
 	if (vi->mergeable_rx_bufs)
-		hdr_padded_len = sizeof *hdr;
+		hdr_padded_len = sizeof(*hdr);
 	else
 		hdr_padded_len = sizeof(struct padded_vnet_hdr);
 
-- 
2.11.0
