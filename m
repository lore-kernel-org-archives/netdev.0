From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ax25: endian-annotate ax25_type_trans()
Date: Mon, 20 Jun 2005 00:26:04 +0400
Message-ID: <200506200026.04525.adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	Al Viro <viro@parcelfarce.linux.theplanet.co.uk>
Return-path: <linux-hams-owner@vger.kernel.org>
To: Ralf Baechle <ralf@linux-mips.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Index: linux-sparse/include/net/ax25.h
===================================================================
--- linux-sparse.orig/include/net/ax25.h	2005-06-10 09:24:10.000000000 +0400
+++ linux-sparse/include/net/ax25.h	2005-06-10 15:03:30.000000000 +0400
@@ -220,7 +220,7 @@ static __inline__ void ax25_cb_put(ax25_
 	}
 }
 
-static inline unsigned short ax25_type_trans(struct sk_buff *skb, struct net_device *dev)
+static inline __be16 ax25_type_trans(struct sk_buff *skb, struct net_device *dev)
 {
 	skb->dev      = dev;
 	skb->pkt_type = PACKET_HOST;
