From: Dan Carpenter <error27@gmail.com>
Subject: [patch] plip: remove superflous return
Date: Tue, 24 Aug 2010 14:01:05 +0200
Message-ID: <20100824120105.GF29330@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:47207 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375Ab0HXMBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 08:01:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This return isn't reachable and it obscures the goto on the line before.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index ec0349e..7e82a82 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -1279,7 +1279,6 @@ static void plip_attach (struct parport *port)
 		if (!nl->pardev) {
 			printk(KERN_ERR "%s: parport_register failed\n", name);
 			goto err_free_dev;
-			return;
 		}
 
 		plip_init_netdev(dev);
