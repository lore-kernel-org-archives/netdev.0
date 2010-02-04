From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: [PATCH 2.6.33 3/4] net: Makefile change for KSZ884X driver
Date: Thu, 4 Feb 2010 15:26:32 -0800
Message-ID: <14385191E87B904DBD836449AA30269D021A54@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c11o148.mxlogic.net ([208.65.144.71]:59312 "EHLO
	p01c11o148.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932699Ab0BDX0j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 18:26:39 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tristram Ha <Tristram.Ha@micrel.com>

Add Micrel KSZ884X network driver for KSZ8841/KSZ8842 PCI Ethernet chips.

Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
---
This is a resubmission of the Micrel KSZ8841/2 PCI Ethernet driver.

--- linux-2.6.33-rc3.old/drivers/net/Makefile	2010-01-05 16:02:46.000000000 -0800
+++ linux-2.6.33-rc3.new/drivers/net/Makefile	2010-01-12 18:56:37.000000000 -0800
@@ -95,6 +95,7 @@ obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_KS8842)	+= ks8842.o
 obj-$(CONFIG_KS8851)	+= ks8851.o
 obj-$(CONFIG_KS8851_MLL)	+= ks8851_mll.o
+obj-$(CONFIG_KSZ884X_PCI)	+= ksz884x.o
 obj-$(CONFIG_VIA_RHINE) += via-rhine.o
 obj-$(CONFIG_VIA_VELOCITY) += via-velocity.o
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
