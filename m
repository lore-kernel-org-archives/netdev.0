From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/16) donauboe -- use alloc_irdadev
Date: Tue, 30 Sep 2003 15:04:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930150407.18dad5dc.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nru a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
--- a/drivers/net/irda/donauboe.c	Tue Sep 30 11:56:29 2003
+++ b/drivers/net/irda/donauboe.c	Tue Sep 30 11:56:29 2003
@@ -1598,8 +1598,7 @@
   if ((err=pci_enable_device(pci_dev)))
     return err;
 
-  dev = alloc_netdev(sizeof (struct toshoboe_cb), "irda%d",
-		     irda_device_setup);
+  dev = alloc_irdadev(sizeof (struct toshoboe_cb));
   if (dev == NULL)
     {
       printk (KERN_ERR DRIVER_NAME ": can't allocate memory for "
