From: akpm@osdl.org
Subject: [patch 08/13] Log full of "ing_filter:  fixed  ippp2 out ippp2"
Date: Tue, 15 Mar 2005 14:22:45 -0800
Message-ID: <200503152222.j2FMMeT6016814@shell0.pdx.osdl.net>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, hadi@cyberus.ca
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: jamal <hadi@cyberus.ca>



Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/isdn/i4l/isdn_net.c |    1 +
 25-akpm/drivers/isdn/i4l/isdn_ppp.c |    1 +
 2 files changed, 2 insertions(+)

diff -puN drivers/isdn/i4l/isdn_net.c~log-full-of-ing_filter-fixed-ippp2-out-ippp2 drivers/isdn/i4l/isdn_net.c
--- 25/drivers/isdn/i4l/isdn_net.c~log-full-of-ing_filter-fixed-ippp2-out-ippp2	Tue Mar 15 14:19:53 2005
+++ 25-akpm/drivers/isdn/i4l/isdn_net.c	Tue Mar 15 14:19:53 2005
@@ -1786,6 +1786,7 @@ isdn_net_receive(struct net_device *ndev
 		lp->stats.rx_bytes += skb->len;
 	}
 	skb->dev = ndev;
+	skb->input_dev = ndev;
 	skb->pkt_type = PACKET_HOST;
 	skb->mac.raw = skb->data;
 #ifdef ISDN_DEBUG_NET_DUMP
diff -puN drivers/isdn/i4l/isdn_ppp.c~log-full-of-ing_filter-fixed-ippp2-out-ippp2 drivers/isdn/i4l/isdn_ppp.c
--- 25/drivers/isdn/i4l/isdn_ppp.c~log-full-of-ing_filter-fixed-ippp2-out-ippp2	Tue Mar 15 14:19:53 2005
+++ 25-akpm/drivers/isdn/i4l/isdn_ppp.c	Tue Mar 15 14:19:53 2005
@@ -1177,6 +1177,7 @@ isdn_ppp_push_higher(isdn_net_dev * net_
 		mlp->huptimer = 0;
 #endif /* CONFIG_IPPP_FILTER */
 	skb->dev = dev;
+	skb->input_dev = dev;
 	skb->mac.raw = skb->data;
 	netif_rx(skb);
 	/* net_dev->local->stats.rx_packets++; done in isdn_net.c */
_
