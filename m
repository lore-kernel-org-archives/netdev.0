From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (9/16) via-ircc use alloc_irdadev
Date: Tue, 30 Sep 2003 15:08:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930150838.6ee2854a.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nru a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
--- a/drivers/net/irda/via-ircc.c	Tue Sep 30 11:56:39 2003
+++ b/drivers/net/irda/via-ircc.c	Tue Sep 30 11:56:39 2003
@@ -335,8 +335,7 @@
 		return -1;
 
 	/* Allocate new instance of the driver */
-	dev = alloc_netdev(sizeof(struct via_ircc_cb), "irda%d",
-			   irda_device_setup);
+	dev = alloc_irdadev(sizeof(struct via_ircc_cb));
 	if (dev == NULL) 
 		return -ENOMEM;
 
