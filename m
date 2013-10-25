From: Matt Zanchelli <zanchm@rpi.edu>
Subject: [PATCH net-next] macsonic: Updated printk() statement to netdev_info function
Date: Fri, 25 Oct 2013 21:53:20 +0000
Message-ID: <1382738000-24202-1-git-send-email-zanchm@rpi.edu>
Cc: Matt Zanchelli <zanchm@rpi.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp9.server.rpi.edu ([128.113.2.229]:53280 "EHLO
	smtp9.server.rpi.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868Ab3JYVx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 17:53:27 -0400
Received: from smtp-auth1.server.rpi.edu (route.canit.rpi.edu [128.113.2.231])
	by smtp9.server.rpi.edu (8.14.3/8.14.3/Debian-9.4) with ESMTP id r9PLrQIu032493
	for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 17:53:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated the printk() statement in mac_sonic_probe() to recommended netdev_info.

Reviewed-by: Mukkai Krishnamoorthy <mskmoorthy@gmail.com>
Reviewed-by: Maxwell Ensley-Field <mensleyfield@gmail.com>
Reviewed-by: Nicole Negedly <nnegedly@gmail.com>
Reviewed-by: Daniel Felizardo <danfelizardo@gmail.com>
Signed-off-by: Matt Zanchelli <zanchm@rpi.edu>
---
 drivers/net/ethernet/natsemi/macsonic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index 346a4e0..9e9b3b0 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -601,7 +601,7 @@ found:
 	if (err)
 		goto out;
 
-	printk("%s: MAC %pM IRQ %d\n", dev->name, dev->dev_addr, dev->irq);
+	netdev_info(dev, "MAC %pM IRQ %d\n", dev->dev_addr, dev->irq);
 
 	return 0;
 
-- 
1.8.1.2
