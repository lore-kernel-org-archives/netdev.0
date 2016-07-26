From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/3] virtio: cleanup sizeof usage
Date: Tue, 26 Jul 2016 09:20:10 -0700
Message-ID: <20160726162036.179433604@networkplumber.org>
References: <20160726162008.310530368@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34425 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756983AbcGZQUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 12:20:21 -0400
Received: by mail-pf0-f171.google.com with SMTP id p64so1279219pfb.1
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 09:20:21 -0700 (PDT)
Content-Disposition: inline; filename=virtio-sizeof.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although sizeof is an operator in C. Preferred usage is to use
it as a function.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/virtio_net.c	2016-07-26 09:13:16.173384238 -0700
+++ b/drivers/net/virtio_net.c	2016-07-26 09:13:16.169384220 -0700
@@ -272,7 +272,7 @@ static struct sk_buff *page_to_skb(struc
 
 	hdr_len = vi->hdr_len;
 	if (vi->mergeable_rx_bufs)
-		hdr_padded_len = sizeof *hdr;
+		hdr_padded_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
 	else
 		hdr_padded_len = sizeof(struct padded_vnet_hdr);
 
