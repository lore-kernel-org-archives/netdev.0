From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: netdrv: Fix unregister_netdev typos
Date: Sun, 5 Oct 2008 12:30:38 +0800
Message-ID: <20081005043038.GA12449@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47652 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751144AbYJEEao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 00:30:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

netdrv: Fix unregister_netdev typos

Found during the (partial) unregister_netdevice audit that we didn't
have to have :)

It looks like a couple of Sun NIC drivers had unregister_netdevice
when they really meant unregister_netdev.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 656a260..06e6823 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -1118,7 +1118,7 @@ static int __devexit myri_sbus_remove(struct of_device *dev)
 	struct myri_eth *mp = dev_get_drvdata(&dev->dev);
 	struct net_device *net_dev = mp->dev;
 
-	unregister_netdevice(net_dev);
+	unregister_netdev(net_dev);
 
 	free_irq(net_dev->irq, net_dev);
 
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index 0e4a88d..31e7384 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -1274,7 +1274,7 @@ static int __devexit bigmac_sbus_remove(struct of_device *dev)
 	struct bigmac *bp = dev_get_drvdata(&dev->dev);
 	struct net_device *net_dev = bp->dev;
 
-	unregister_netdevice(net_dev);
+	unregister_netdev(net_dev);
 
 	sbus_iounmap(bp->gregs, GLOB_REG_SIZE);
 	sbus_iounmap(bp->creg, CREG_REG_SIZE);
