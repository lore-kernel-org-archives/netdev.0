From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 2/2] typhoon: use netdev_priv
Date: Fri, 15 Oct 2004 13:55:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015135541.435cfe39@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use netdev_priv instead of dev->priv

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	2004-10-15 12:56:42 -07:00
+++ b/drivers/net/typhoon.c	2004-10-15 12:56:42 -07:00
@@ -1778,7 +1778,7 @@
 typhoon_interrupt(int irq, void *dev_instance, struct pt_regs *rgs)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
-	struct typhoon *tp = dev->priv;
+	struct typhoon *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->ioaddr;
 	u32 intr_status;
 
