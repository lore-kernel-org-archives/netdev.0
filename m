From: Marcos Paulo de Souza <marcos.mage@gmail.com>
Subject: [PATCH] include: linux: skbuf.h: Fix parameter documentation
Date: Mon, 31 Oct 2011 23:11:45 -0200
Message-ID: <1320109905-12721-1-git-send-email-marcos.mage@gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Marcos Paulo de Souza <marcos.mage@gmail.com>
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:60613 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067Ab1KABL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2011 21:11:57 -0400
Received: by gyb13 with SMTP id 13so6492621gyb.19
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2011 18:11:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes parameter name of skb_frag_dmamap function to silence warning on
make htmldocs.

Signed-off-by: Marcos Paulo de Souza <marcos.mage@gmail.com>
---
 include/linux/skbuff.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6a6b352..fe86488 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1806,12 +1806,12 @@ static inline void skb_frag_set_page(struct sk_buff *skb, int f,
 
 /**
  * skb_frag_dma_map - maps a paged fragment via the DMA API
- * @device: the device to map the fragment to
+ * @dev: the device to map the fragment to
  * @frag: the paged fragment to map
  * @offset: the offset within the fragment (starting at the
  *          fragment's own offset)
  * @size: the number of bytes to map
- * @direction: the direction of the mapping (%PCI_DMA_*)
+ * @dir: the direction of the mapping (%PCI_DMA_*)
  *
  * Maps the page associated with @frag to @device.
  */
-- 
1.7.4.1
