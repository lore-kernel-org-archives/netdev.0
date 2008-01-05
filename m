From: Adrian Bunk <adrian.bunk@movial.fi>
Subject: [2.6.24 patch] fix netx-eth.c compilation
Date: Sat, 5 Jan 2008 23:46:16 +0200
Message-ID: <20080105214616.GE22232@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:48905 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756667AbYAEVqr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2008 16:46:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was missed when commit e2ac455a18806b31c2d0da0a51d8740af5010b7a 
fixed the compile errors in drivers/net/netx-eth.c caused by
commit 09f75cd7bf13720738e6a196cc0107ce9a5bd5a0.

Signed-off-by: Adrian Bunk <adrian.bunk@movial.fi>

---
15e5efb728c61333ca10648334185efba86c4815 
diff --git a/drivers/net/netx-eth.c b/drivers/net/netx-eth.c
index 5267e03..78d34af 100644
--- a/drivers/net/netx-eth.c
+++ b/drivers/net/netx-eth.c
@@ -169,8 +169,8 @@ static void netx_eth_receive(struct net_device *ndev)
 	ndev->last_rx = jiffies;
 	skb->protocol = eth_type_trans(skb, ndev);
 	netif_rx(skb);
-	dev->stats.rx_packets++;
-	dev->stats.rx_bytes += len;
+	ndev->stats.rx_packets++;
+	ndev->stats.rx_bytes += len;
 }
 
 static irqreturn_t

