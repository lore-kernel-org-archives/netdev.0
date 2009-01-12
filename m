From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] Fix a comment in include/linux/netdevice.h.
Date: Mon, 12 Jan 2009 02:05:02 +0100
Message-ID: <m3prit49mp.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:39040 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751907AbZALBFE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 20:05:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix a comment in include/linux/netdevice.h.
   =20
Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f245568..4647604 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -467,7 +467,7 @@ struct netdev_queue {
  *     This function is called when network device transistions to the=
 down
  *     state.
  *
- * int (*ndo_hard_start_xmit)(struct sk_buff *skb, struct net_device *=
dev);
+ * int (*ndo_start_xmit)(struct sk_buff *skb, struct net_device *dev);
  *	Called when a packet needs to be transmitted.
  *	Must return NETDEV_TX_OK , NETDEV_TX_BUSY, or NETDEV_TX_LOCKED,
  *	Required can not be NULL.

--=20
Krzysztof Halasa
