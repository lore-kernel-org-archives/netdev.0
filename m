From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] 3c59x netpoll typo
Date: Tue, 11 Nov 2003 14:43:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111144354.2542488e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Poll code (in net-drivers-2.5-exp) was calling undefined function.

diff -Nru a/drivers/net/3c59x.c b/drivers/net/3c59x.c
--- a/drivers/net/3c59x.c	Tue Nov 11 09:59:30 2003
+++ b/drivers/net/3c59x.c	Tue Nov 11 09:59:30 2003
@@ -928,7 +928,7 @@
 	local_save_flags(flags);
 	local_irq_disable();
 	(vp->full_bus_master_rx ? boomerang_interrupt:vortex_interrupt)(dev->irq,dev,NULL);
-	local_restore_flags(flags);
+	local_irq_restore(flags);
 } 
 #endif
 
