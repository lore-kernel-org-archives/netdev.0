From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Subject: mv643xx: convert to netdev_tx_t
Date: Sun, 29 Nov 2009 19:21:24 +0300
Message-ID: <20091129162123.GA17782@coldcone>
Reply-To: kirjanov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:53608 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbZK2QTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 11:19:34 -0500
Received: by bwz27 with SMTP id 27so2003936bwz.21
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2009 08:19:39 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


---
drivers/net/mv643xx_eth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index b62e61d..796a493 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -849,7 +849,7 @@ no_csum:
 	return 0;
 }
 
-static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int queue;
