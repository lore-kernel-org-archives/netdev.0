From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [HAMRADIO] Remove remaining SET_MODULE_OWNER calls from hamradio drivers.
Date: Sat, 29 Apr 2006 15:34:13 +0100
Message-ID: <20060429143413.GA4630@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:26249 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1750785AbWD2SrN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 14:47:13 -0400
Received: from localhost.localdomain ([127.0.0.1]:59333 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133576AbWD2SrM (ORCPT
	<rfc822;netdev@vger.kernel.org> + 1 other);
	Sat, 29 Apr 2006 19:47:12 +0100
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

--

 drivers/net/hamradio/dmascc.c |    1 -
 drivers/net/hamradio/scc.c    |    1 -
 drivers/net/hamradio/yam.c    |    1 -
 3 files changed, 3 deletions(-)

Index: linux-net.git/drivers/net/hamradio/dmascc.c
===================================================================
--- linux-net.git.orig/drivers/net/hamradio/dmascc.c	2006-04-29 01:54:04.000000000 +0100
+++ linux-net.git/drivers/net/hamradio/dmascc.c	2006-04-29 11:38:06.000000000 +0100
@@ -582,7 +582,6 @@ static int __init setup_adapter(int card
 		INIT_WORK(&priv->rx_work, rx_bh, priv);
 		dev->priv = priv;
 		sprintf(dev->name, "dmascc%i", 2 * n + i);
-		SET_MODULE_OWNER(dev);
 		dev->base_addr = card_base;
 		dev->irq = irq;
 		dev->open = scc_open;
Index: linux-net.git/drivers/net/hamradio/scc.c
===================================================================
--- linux-net.git.orig/drivers/net/hamradio/scc.c	2006-04-29 01:43:47.000000000 +0100
+++ linux-net.git/drivers/net/hamradio/scc.c	2006-04-29 11:38:06.000000000 +0100
@@ -1550,7 +1550,6 @@ static unsigned char ax25_nocall[AX25_AD
 
 static void scc_net_setup(struct net_device *dev)
 {
-	SET_MODULE_OWNER(dev);
 	dev->tx_queue_len    = 16;	/* should be enough... */
 
 	dev->open            = scc_net_open;
Index: linux-net.git/drivers/net/hamradio/yam.c
===================================================================
--- linux-net.git.orig/drivers/net/hamradio/yam.c	2006-04-29 01:43:47.000000000 +0100
+++ linux-net.git/drivers/net/hamradio/yam.c	2006-04-29 11:38:06.000000000 +0100
@@ -1098,7 +1098,6 @@ static void yam_setup(struct net_device 
 
 	dev->base_addr = yp->iobase;
 	dev->irq = yp->irq;
-	SET_MODULE_OWNER(dev);
 
 	dev->open = yam_open;
 	dev->stop = yam_close;
