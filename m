From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 2/2] b44: use netdev_priv
Date: Fri, 15 Oct 2004 13:03:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015130308.2965d8b3@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace uses of dev->priv with netdev_priv

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/b44.c b/drivers/net/b44.c
--- a/drivers/net/b44.c	2004-10-15 12:23:59 -07:00
+++ b/drivers/net/b44.c	2004-10-15 12:23:59 -07:00
@@ -1885,7 +1885,7 @@
 static int b44_suspend(struct pci_dev *pdev, u32 state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct b44 *bp = dev->priv;
+	struct b44 *bp = netdev_priv(dev);
 
         if (!netif_running(dev))
                  return 0;
@@ -1906,7 +1906,7 @@
 static int b44_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct b44 *bp = dev->priv;
+	struct b44 *bp = netdev_priv(dev);
 
 	pci_restore_state(pdev, bp->pci_cfg_state);
 
