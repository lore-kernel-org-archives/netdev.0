From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 1/4 linux-2.6.9-rc3/linux-2.4.28-pre3]
	prism54 remove TRACE
Date: Sat, 2 Oct 2004 16:39:48 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200410021639.48960.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_02rXBe1fWCdgDwu"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://mcgrof.com/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_02rXBe1fWCdgDwu
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-10-02 Margit Schubert-While <margitsw@t-online.de>

* 01_remtrace.patch
*  Remove TRACE to please the janitors

Margit

















--Boundary-00=_02rXBe1fWCdgDwu
Content-Type: text/x-diff;
  charset="us-ascii";
  name="01_remtrace.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="01_remtrace.patch"

diff -Naur linux-2.6.9rc2/drivers/net/wireless/prism54/islpci_hotplug.c linux-2.6.9-rc2msw/drivers/net/wireless/prism54/islpci_hotplug.c
--- linux-2.6.9rc2/drivers/net/wireless/prism54/islpci_hotplug.c	2004-08-14 07:36:57.000000000 +0200
+++ linux-2.6.9-rc2msw/drivers/net/wireless/prism54/islpci_hotplug.c	2004-09-25 11:15:41.000000000 +0200
@@ -107,9 +107,6 @@
 	islpci_private *priv;
 	int rvalue;
 
-	/* TRACE(DRV_NAME); */
-	
-	
 	/* Enable the pci device */
 	if (pci_enable_device(pdev)) {
 		printk(KERN_ERR "%s: pci_enable_device() failed.\n", DRV_NAME);
diff -Naur linux-2.6.9rc2/drivers/net/wireless/prism54/islpci_mgt.h linux-2.6.9-rc2msw/drivers/net/wireless/prism54/islpci_mgt.h
--- linux-2.6.9rc2/drivers/net/wireless/prism54/islpci_mgt.h	2004-08-14 07:36:18.000000000 +0200
+++ linux-2.6.9-rc2msw/drivers/net/wireless/prism54/islpci_mgt.h	2004-09-25 11:15:54.000000000 +0200
@@ -31,8 +31,6 @@
 #define K_DEBUG(f, m, args...) do { if(f & m) printk(KERN_DEBUG args); } while(0)
 #define DEBUG(f, args...) K_DEBUG(f, pc_debug, args)
 
-#define TRACE(devname)   K_DEBUG(SHOW_TRACING, VERBOSE, "%s:  -> " __FUNCTION__ "()\n", devname)
-
 extern int pc_debug;
 #define init_wds 0	/* help compiler optimize away dead code */
 

--Boundary-00=_02rXBe1fWCdgDwu
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_02rXBe1fWCdgDwu--
