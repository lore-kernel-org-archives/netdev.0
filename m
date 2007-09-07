From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 1/2] atl1: add CONFIG_ATL1_EXPERIMENTAL to kconfig
Date: Fri, 7 Sep 2007 19:47:46 -0400
Message-ID: <20070907234746.GA12055@shell.boston.redhat.com>
References: <46E1E1AC.5030801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: atl1-devel@lists.sourceforge.net,
	Jay Cliburn <jacliburn@bellsouth.net>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51474 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751176AbXIGXr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 19:47:57 -0400
Content-Disposition: inline
In-Reply-To: <46E1E1AC.5030801@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Introduce Kconfig ATL1_EXPERIMENTAL to separate mature code from less mature
code in the atl1 driver, and remove EXPERIMENTAL designation for ATL1.

Signed-off-by: Chris Snook <csnook@redhat.com>
Acked-by: Jay Cliburn <jacliburn@bellsouth.net>

--- a/drivers/net/Kconfig	2007-09-04 10:12:38.000000000 -0400
+++ b/drivers/net/Kconfig	2007-09-04 10:37:34.000000000 -0400
@@ -2329,8 +2329,8 @@ config QLA3XXX
 	  will be called qla3xxx.
 
 config ATL1
-	tristate "Attansic L1 Gigabit Ethernet support (EXPERIMENTAL)"
-	depends on PCI && EXPERIMENTAL
+	tristate "Attansic L1 Gigabit Ethernet support"
+	depends on PCI
 	select CRC32
 	select MII
 	help
@@ -2339,6 +2339,16 @@ config ATL1
 	  To compile this driver as a module, choose M here.  The module
 	  will be called atl1.
 
+config ATL1_EXPERIMENTAL
+	bool "atl1 experimental features"
+	depends on ATL1 && EXPERIMENTAL
+	help
+	  This option enables various features that have not yet reached
+	  the maturity of the rest of the atl1 driver.  The driver will
+	  still work fine without this option enabled.
+
+	  If unsure, say N.
+
 endif # NETDEV_1000
 
 #
