From: Matt Zanchelli <zanchm@rpi.edu>
Subject: [PATCH net-next] macsonic: Updated printk() statement to KERN style leading argument.
Date: Thu, 24 Oct 2013 21:37:25 +0000
Message-ID: <1382650645-23973-1-git-send-email-zanchm@rpi.edu>
Cc: Matt Zanchelli <zanchm@rpi.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.canit.rpi.edu ([128.113.2.229]:51825 "EHLO
	smtp9.server.rpi.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037Ab3JXVrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 17:47:15 -0400
Received: from smtp-auth1.server.rpi.edu (smtp-auth1.server.rpi.edu [128.113.2.231])
	by smtp9.server.rpi.edu (8.14.3/8.14.3/Debian-9.4) with ESMTP id r9OLbUcD028731
	for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 17:37:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated prinkt() statement in mac_sonic_probe() function to match current
convention of using KERN style leading argument.

Reviewed-by: Daniel Felizardo <danfelizardo@gmail.com>
Reviewed-by: Nicole Negedly <nnegedly@gmail.com>
Reviewed-by: Maxwell Ensley-Field <mensleyfield@gmail.com>
Signed-off-by: Matt Zanchelli <zanchm@rpi.edu>
---
 drivers/net/ethernet/natsemi/macsonic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index 346a4e0..3eca756 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -601,7 +601,7 @@ found:
 	if (err)
 		goto out;
 
-	printk("%s: MAC %pM IRQ %d\n", dev->name, dev->dev_addr, dev->irq);
+	printk(KERN_INFO "%s: MAC %pM IRQ %d\n", dev->name, dev->dev_addr, dev->irq);
 
 	return 0;
 
-- 
1.8.1.2
