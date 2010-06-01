From: Dan Carpenter <error27@gmail.com>
Subject: [patch 1/2] caif: remove unneeded variable from caif_net_open()
Date: Tue, 1 Jun 2010 09:08:55 +0200
Message-ID: <20100601070855.GD5483@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49321 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926Ab0FAHJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 03:09:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't use the "ser" variable so I've removed it.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
index 09257ca..f30a6a0 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -410,8 +410,6 @@ static void caifdev_setup(struct net_device *dev)
 
 static int caif_net_open(struct net_device *dev)
 {
-	struct ser_device *ser;
-	ser = netdev_priv(dev);
 	netif_wake_queue(dev);
 	return 0;
 }
