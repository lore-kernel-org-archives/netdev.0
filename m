From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 2/2] r8169: use netdev_priv
Date: Fri, 15 Oct 2004 15:38:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015153804.4ff3fca6@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use netdev_priv in a couple of places in realtek 8169

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c	2004-10-15 15:00:43 -07:00
+++ b/drivers/net/r8169.c	2004-10-15 15:00:43 -07:00
@@ -1119,7 +1119,7 @@
 
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 
 	// enable device (incl. PCI PM wakeup and hotplug setup)
 	rc = pci_enable_device(pdev);
@@ -1270,7 +1270,7 @@
 	if (rc)
 		return rc;
 
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 	assert(ioaddr != NULL);
 
 	if (RTL_R8(PHYstatus) & TBI_Enable) {
