From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] ibmtr: Drain rich supply of modpost warnings.
Date: Thu, 8 Mar 2007 12:53:07 +0000
Message-ID: <20070308125307.GA10074@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:46272 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbXCHMzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 07:55:22 -0500
Received: from localhost.localdomain ([127.0.0.1]:33414 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021746AbXCHMzO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 12:55:14 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Building ibmtr as a module produces a spectacular pile of modpost warnings:

WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.text:ibmtr_probe1 from .text between 'ibmtr_probe_card' (at offset 0x450) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.text:ibmtr_probe1 from .text between 'ibmtr_probe_card' (at offset 0x454) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.text:ibmtr_probe1 from .text between 'ibmtr_probe_card' (at offset 0x458) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.text:ibmtr_probe1 from .text between 'ibmtr_probe_card' (at offset 0x45c) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.data:ibmtr_portlist from .text between 'ibmtr_probe_card' (at offset 0x4e8) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.data:ibmtr_portlist from .text between 'ibmtr_probe_card' (at offset 0x4ec) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.data:ibmtr_portlist from .text between 'ibmtr_probe_card' (at offset 0x4f0) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.data:ibmtr_portlist from .text between 'ibmtr_probe_card' (at offset 0x4f4) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.text:find_turbo_adapters from .text between 'ibmtr_probe_card' (at offset 0x500) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.text:find_turbo_adapters from .text between 'ibmtr_probe_card' (at offset 0x504) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.text:find_turbo_adapters from .text between 'ibmtr_probe_card' (at offset 0x508) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.text:find_turbo_adapters from .text between 'ibmtr_probe_card' (at offset 0x50c) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.data:ibmtr_portlist from .text between 'ibmtr_probe_card' (at offset 0x520) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.data:ibmtr_portlist from .text between 'ibmtr_probe_card' (at offset 0x524) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.data:ibmtr_portlist from .text between 'ibmtr_probe_card' (at offset 0x528) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.data:ibmtr_portlist from .text between 'ibmtr_probe_card' (at offset 0x534) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.data: from .text between 'ibmtr_probe_card' (at offset 0x540) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.data: from .text between 'ibmtr_probe_card' (at offset 0x544) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.data: from .text between 'ibmtr_probe_card' (at offset 0x548) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.data: from .text between 'ibmtr_probe_card' (at offset 0x54c) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.text:ibmtr_probe1 from .text between 'ibmtr_probe_card' (at offset 0x558) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.text:ibmtr_probe1 from .text between 'ibmtr_probe_card' (at offset 0x55c) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.text:ibmtr_probe1 from .text between 'ibmtr_probe_card' (at offset 0x560) and 'ibmtr_reset_timer'
WARNING: drivers/net/tokenring/ibmtr.o - Section mismatch: reference to .init.text:ibmtr_probe1 from .text between 'ibmtr_probe_card' (at offset 0x564) and 'ibmtr_reset_timer'

Fix by making ibmtr_probe an __init function.

While at it, move move ibmtr_probe_card below ibmtr_probe so the protoype
for ibmtr_probe can be deleted.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 drivers/net/tokenring/ibmtr.c |   25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

Index: linux-mips/drivers/net/tokenring/ibmtr.c
===================================================================
--- linux-mips.orig/drivers/net/tokenring/ibmtr.c
+++ linux-mips/drivers/net/tokenring/ibmtr.c
@@ -186,7 +186,6 @@ static char __devinit *adapter_def(char 
 #define TRC_INITV 0x02		/*  verbose init trace points     */
 static unsigned char ibmtr_debug_trace = 0;
 
-static int 	ibmtr_probe(struct net_device *dev);
 static int	ibmtr_probe1(struct net_device *dev, int ioaddr);
 static unsigned char get_sram_size(struct tok_info *adapt_info);
 static int 	trdev_init(struct net_device *dev);
@@ -335,17 +334,6 @@ static void ibmtr_cleanup_card(struct ne
 #endif		
 }
 
-int ibmtr_probe_card(struct net_device *dev)
-{
-	int err = ibmtr_probe(dev);
-	if (!err) {
-		err = register_netdev(dev);
-		if (err)
-			ibmtr_cleanup_card(dev);
-	}
-	return err;
-}
-
 /****************************************************************************
  *	ibmtr_probe():  Routine specified in the network device structure
  *	to probe for an IBM Token Ring Adapter.  Routine outline:
@@ -358,7 +346,7 @@ int ibmtr_probe_card(struct net_device *
  *	which references it.
  ****************************************************************************/
 
-static int ibmtr_probe(struct net_device *dev)
+static int __init ibmtr_probe(struct net_device *dev)
 {
 	int i;
 	int base_addr = dev->base_addr;
@@ -378,6 +366,17 @@ static int ibmtr_probe(struct net_device
 	return -ENODEV;
 }
 
+int __init ibmtr_probe_card(struct net_device *dev)
+{
+	int err = ibmtr_probe(dev);
+	if (!err) {
+		err = register_netdev(dev);
+		if (err)
+			ibmtr_cleanup_card(dev);
+	}
+	return err;
+}
+
 /*****************************************************************************/
 
 static int __devinit ibmtr_probe1(struct net_device *dev, int PIOaddr)
