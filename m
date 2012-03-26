From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] eql: Fix byte stats
Date: Mon, 26 Mar 2012 08:29:35 +0100
Message-ID: <1332746975.2379.5.camel@shinybook.infradead.org>
References: <1332669700.32446.142.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55635 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477Ab2CZH3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 03:29:37 -0400
Received: from dyn-247.woodhou.se ([90.155.92.247])
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1SC4Mx-0007nU-R8
	for netdev@vger.kernel.org; Mon, 26 Mar 2012 07:29:35 +0000
In-Reply-To: <1332669700.32446.142.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
Sorry, forgot to tell Evolution not to word-wrap last time. It's a
manual process =E2=80=94 insert the patch from a text file, and set it =
to
'Preformatted'. I've also disabled the signature on this version; I'm
not entirely sure if the git-am bug with QP got fixed yet.

diff --git a/drivers/net/eql.c b/drivers/net/eql.c
index a59cf96..f2d3741 100644
--- a/drivers/net/eql.c
+++ b/drivers/net/eql.c
@@ -345,6 +345,7 @@ static netdev_tx_t eql_slave_xmit(struct sk_buff *s=
kb, struct net_device *dev)
 		slave->bytes_queued +=3D skb->len;
 		dev_queue_xmit(skb);
 		dev->stats.tx_packets++;
+		dev->stats.tx_bytes +=3D skb->len;
 	} else {
 		dev->stats.tx_dropped++;
 		dev_kfree_skb(skb);

--=20
dwmw2
