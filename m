From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sis190 - missing arg to synchronize irq
Date: Tue, 19 Aug 2003 16:03:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819160349.3e139fdd.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don't have this hardware, but it looks like a simple "never been
built on SMP" typo.

diff -Nru a/drivers/net/sis190.c b/drivers/net/sis190.c
--- a/drivers/net/sis190.c	Tue Aug 19 16:02:43 2003
+++ b/drivers/net/sis190.c	Tue Aug 19 16:02:43 2003
@@ -1111,7 +1111,7 @@
 
 	spin_unlock_irq(&tp->lock);
 
-	synchronize_irq();
+	synchronize_irq(dev->irq);
 	free_irq(dev->irq, dev);
 
 	SiS190_tx_clear(tp);
