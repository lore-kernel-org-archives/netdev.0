From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 1/2 linux-2.6.9-rc3/linux-2.4.28-pre4]
	prism54 fix resume processing
Date: Sun, 17 Oct 2004 14:08:06 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200410101530.08274.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_mCmcBauZdA0KsYS"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_mCmcBauZdA0KsYS
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-10-17 Margit Schubert-While <margitsw@t-online.de>

* 01_fix_resume.patch
*  We need to enable the device on resume.

Margit








--Boundary-00=_mCmcBauZdA0KsYS
Content-Type: text/x-diff;
  charset="us-ascii";
  name="01_fix_resume.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="01_fix_resume.patch"

diff -Naur linux-2.6.9rc3/drivers/net/wireless/prism54/islpci_hotplug.c linux-2.6.9-rc3msw/drivers/net/wireless/prism54/islpci_hotplug.c
--- linux-2.6.9rc3/drivers/net/wireless/prism54/islpci_hotplug.c	2004-10-02 12:25:47.000000000 +0200
+++ linux-2.6.9-rc3msw/drivers/net/wireless/prism54/islpci_hotplug.c	2004-10-07 19:16:27.000000000 +0200
@@ -292,6 +292,8 @@
 	islpci_private *priv = ndev ? netdev_priv(ndev) : NULL;
 	BUG_ON(!priv);
 
+	pci_enable_device(pdev);
+
 	printk(KERN_NOTICE "%s: got resume request\n", ndev->name);
 
 	pci_restore_state(pdev, priv->pci_state);

--Boundary-00=_mCmcBauZdA0KsYS
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_mCmcBauZdA0KsYS--
