From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 16/16] drivers/net/wireless/rtl818x: remove exceptional & on
 function name
Date: Wed, 18 Nov 2009 19:26:02 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0911181925440.20943@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	arnd@arndb.de, joe@perches.com, linux-kernel@vger.kernel.org,
	kernel-janitors@vger
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:59995 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932389AbZKRSZ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 13:25:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

In this file, function names are otherwise used as pointers without &.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@r@
identifier f;
@@

f(...) { ... }

@@
identifier r.f;
@@

- &f
+ f
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/rtl818x/rtl8180_dev.c     |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/rtl818x/rtl8180_dev.c b/drivers/net/wireless/rtl818x/rtl8180_dev.c
index 16429c4..a1a3dd1 100644
--- a/drivers/net/wireless/rtl818x/rtl8180_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180_dev.c
@@ -548,7 +548,7 @@ static int rtl8180_start(struct ieee80211_hw *dev)
 	rtl818x_iowrite32(priv, &priv->map->TNPDA, priv->tx_ring[1].dma);
 	rtl818x_iowrite32(priv, &priv->map->TLPDA, priv->tx_ring[0].dma);
 
-	ret = request_irq(priv->pdev->irq, &rtl8180_interrupt,
+	ret = request_irq(priv->pdev->irq, rtl8180_interrupt,
 			  IRQF_SHARED, KBUILD_MODNAME, dev);
 	if (ret) {
 		printk(KERN_ERR "%s: failed to register IRQ handler\n",
