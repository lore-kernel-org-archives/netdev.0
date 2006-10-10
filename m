From: akpm@osdl.org
Subject: [patch 7/7] ibmveth irq fix
Date: Tue, 10 Oct 2006 14:33:30 -0700
Message-ID: <200610102133.k9ALXUC6024980@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, anton@samba.org,
	paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:52633 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030447AbWJJVdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2006 17:33:37 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Andrew Morton <akpm@osdl.org>

drivers/net/ibmveth.c:939: error: too many arguments to function `ibmveth_interrupt'

Cc: Jeff Garzik <jeff@garzik.org>
Cc: Anton Blanchard <anton@samba.org>
Cc: Paul Mackerras <paulus@samba.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/ibmveth.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/ibmveth.c~ibmveth-irq-fix drivers/net/ibmveth.c
--- a/drivers/net/ibmveth.c~ibmveth-irq-fix
+++ a/drivers/net/ibmveth.c
@@ -936,7 +936,7 @@ static int ibmveth_change_mtu(struct net
 static void ibmveth_poll_controller(struct net_device *dev)
 {
 	ibmveth_replenish_task(dev->priv);
-	ibmveth_interrupt(dev->irq, dev, NULL);
+	ibmveth_interrupt(dev->irq, dev);
 }
 #endif
 
_
