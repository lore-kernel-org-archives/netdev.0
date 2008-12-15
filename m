From: Samuel Ortiz <samuel@sortiz.org>
Subject: [RFC PATCH 8/9] irda: Add a WARN_ON when our head room is too small
Date: Mon, 15 Dec 2008 02:57:37 +0100
Message-ID: <20081215015903.905115415@sortiz.org>
References: <20081215015729.587697008@sortiz.org>
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 42.mail-out.ovh.net ([213.251.189.42]:35476 "HELO
	42.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751793AbYLOCDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 21:03:13 -0500
Content-Disposition: inline; filename=0008-irda-Add-a-WARN_ON-when-our-head-room-is-too-small.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 include/net/irda/irda_device.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/irda/irda_device.h b/include/net/irda/irda_device.h
index 3bbf695..28c690c 100644
--- a/include/net/irda/irda_device.h
+++ b/include/net/irda/irda_device.h
@@ -233,6 +233,7 @@ void irda_setup_dma(int channel, dma_addr_t buffer, int count, int mode);
 
 static inline struct irda_skb_cb *irda_get_skb_cb(struct sk_buff *skb)
 {
+	WARN_ON(skb_headroom(skb) < sizeof(struct irda_skb_cb));
 	return (struct irda_skb_cb *)(skb->data - sizeof(struct irda_skb_cb));
 }
 
-- 
1.6.0.4.766.g6fc4a.dirty

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
