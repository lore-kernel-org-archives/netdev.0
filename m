From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (13/25) sk98: pci device id not used.
Date: Mon, 15 Nov 2004 15:35:18 -0800
Message-ID: <20041115153518.0ba1ab67@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

PCI device id is saved but never used.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-15 13:34:33 -08:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-15 13:34:33 -08:00
@@ -399,7 +399,6 @@
 	SK_IOC		IoBase;		/* register set of adapter */
 	int		BoardLevel;	/* level of active hw init (0-2) */
 	struct pci_dev	*PciDev;	/* for access to pci config space */
-	SK_U32		PciDevId;	/* pci device id */
 	struct net_device *dev[2];	/* pointer to device struct */
 
 	int		RxBufSize;	/* length of receive buffers */
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 13:34:33 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 13:34:33 -08:00
@@ -4853,7 +4853,6 @@
 	memset(pNet->pAC, 0, sizeof(SK_AC));
 	pAC = pNet->pAC;
 	pAC->PciDev = pdev;
-	pAC->PciDevId = pdev->device;
 	pAC->dev[0] = dev;
 	pAC->dev[1] = dev;
 	strcpy(dev->name, pci_name(pdev)); 
