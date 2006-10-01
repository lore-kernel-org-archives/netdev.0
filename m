From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] atm/firestream: mark 32-bit only
Date: Sun, 1 Oct 2006 10:48:27 -0400
Message-ID: <20061001144827.GA3322@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:18410 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S1750752AbWJAOsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2006 10:48:33 -0400
To: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This driver does some dodgy stuff, reading a 32-bit value directly from
the hardware, calling bus_to_virt() on it, and then pretending that will
work just fine on 64-bit.

Signed-off-by: Jeff Garzik <jeff@garzik.org>

diff --git a/drivers/atm/Kconfig b/drivers/atm/Kconfig
index cfa5af8..8903ecf 100644
--- a/drivers/atm/Kconfig
+++ b/drivers/atm/Kconfig
@@ -139,7 +139,7 @@ config ATM_ENI_BURST_RX_2W
 
 config ATM_FIRESTREAM
 	tristate "Fujitsu FireStream (FS50/FS155) "
-	depends on PCI && ATM
+	depends on PCI && ATM && 32BIT
 	help
 	  Driver for the Fujitsu FireStream 155 (MB86697) and
 	  FireStream 50 (MB86695) ATM PCI chips.
