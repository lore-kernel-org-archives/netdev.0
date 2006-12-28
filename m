From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] Update CREDITS and MAINTAINERS entries for Lennert Buytenhek
Date: Thu, 28 Dec 2006 04:38:00 +0100
Message-ID: <20061228033800.GA31578@xi.wantstofly.org>
References: <200612192108.kBJL8ndY010501@shell0.pdx.osdl.net> <459196FD.7000600@garzik.org> <20061226214227.GB23313@xi.wantstofly.org> <20061226225630.GA20086@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	burman.yan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:49379 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964899AbWL1DiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Dec 2006 22:38:04 -0500
To: Russell King <rmk@arm.linux.org.uk>, akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <20061226225630.GA20086@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 26, 2006 at 10:56:30PM +0000, Russell King wrote:

> > > >Small cleanup in the Cirrus Logic EP93xx ethernet driver: Check for NULL
> > > >pointer before dereferencing it instead of after.  Remove unreferenced
> > > >variable.
> > > >
> > > >Signed-off-by: Yan Burman <burman.yan@gmail.com>
> > > >Cc: Jeff Garzik <jeff@garzik.org>
> > > >Cc: Russell King <rmk@arm.linux.org.uk>
> > > >Signed-off-by: Andrew Morton <akpm@osdl.org>
> > 
> > Why wasn't I CC'ed on this?
> 
> Probably because akpm thinks it was something to do with me... may I
> suggest it might help to have an entry in MAINTAINERS?

You mean the file that still lists Bartlomiej as IDE maintainer?

If people manage to miss the name and email address at the top of the
very file being patched, I'm not sure whether anything else'll help, but
fine, whatever.

The patch below adds a MAINTAINERS entry for everything I would
appreciate being CC'ed on, someone please apply it.

---
From: Lennert Buytenhek <buytenh@wantstofly.org>

Update CREDITS and MAINTAINERS entries for Lennert Buytenhek

Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

Index: linux-2.6.20-rc2/CREDITS
===================================================================
--- linux-2.6.20-rc2.orig/CREDITS
+++ linux-2.6.20-rc2/CREDITS
@@ -516,9 +516,10 @@ S: Orlando, Florida
 S: USA
 
 N: Lennert Buytenhek
-E: buytenh@gnu.org
-D: Rewrite of the ethernet bridging code
-S: Ravenhorst 58B
+E: kernel@wantstofly.org
+D: Original (2.4) rewrite of the ethernet bridging code
+D: Various ARM bits and pieces
+S: Ravenhorst 58
 S: 2317 AK Leiden
 S: The Netherlands
 
Index: linux-2.6.20-rc2/MAINTAINERS
===================================================================
--- linux-2.6.20-rc2.orig/MAINTAINERS
+++ linux-2.6.20-rc2/MAINTAINERS
@@ -355,6 +355,24 @@ P:	Ian Molton
 M:	spyro@f2s.com
 S:	Maintained
 
+ARM/ADI ROADRUNNER MACHINE SUPPORT
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
+ARM/ADS SPHERE MACHINE SUPPORT
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
+ARM/AJECO 1ARM MACHINE SUPPORT
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
 ARM/ATMEL AT91RM9200 ARM ARCHITECTURE
 P:      Andrew Victor
 M:      andrew@sanpeople.com
@@ -362,17 +380,89 @@ L:      linux-arm-kernel@lists.arm.linux
 W:      http://maxim.org.za/at91_26.html
 S:      Maintained
 
+ARM/CIRRUS LOGIC EP93XX ARM ARCHITECTURE
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
+ARM/CIRRUS LOGIC EDB9315A MACHINE SUPPORT
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
 ARM/CORGI MACHINE SUPPORT
 P:	Richard Purdie
 M:	rpurdie@rpsys.net
 S:	Maintained
 
+ARM/GLOMATION GESBC9312SX MACHINE SUPPORT
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
 ARM/HP JORNADA 7XX MACHINE SUPPORT
 P:      Kristoffer Ericson
 M:      kristoffer_e1@hotmail.com
 W:      www.jlime.com
 S:      Maintained
 
+ARM/INTEL IOP32X ARM ARCHITECTURE
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
+ARM/INTEL IOP13XX ARM ARCHITECTURE
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
+ARM/INTEL IQ81342EX MACHINE SUPPORT
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
+ARM/INTEL IXP2000 ARM ARCHITECTURE
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
+ARM/INTEL IXDP2850 MACHINE SUPPORT
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
+ARM/INTEL IXP23XX ARM ARCHITECTURE
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
+ARM/INTEL XSC3 (MANZANO) ARM CORE
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
+ARM/IP FABRICS DOUBLE ESPRESSO MACHINE SUPPORT
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
+ARM/LOGICPD PXA270 MACHINE SUPPORT
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
 ARM/TOSA MACHINE SUPPORT
 P:	Dirk Opfer
 M:	dirk@opfer-online.de
@@ -391,6 +481,12 @@ L:	linux-arm-kernel@lists.arm.linux.org.
 W:	http://www.arm.linux.org.uk/
 S:	Maintained
 
+ARM/RADISYS ENP2611 MACHINE SUPPORT
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
 ARM/SHARK MACHINE SUPPORT
 P:	Alexander Schulz
 M:	alex@shark-linux.de
@@ -418,6 +514,18 @@ L:	linux-arm-kernel@lists.arm.linux.org.
 W:	http://www.fluff.org/ben/linux/
 S:	Maintained
 
+ARM/TECHNOLOGIC SYSTEMS TS7250 MACHINE SUPPORT
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
+ARM/THECUS N2100 MACHINE SUPPORT
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-arm-kernel@lists.arm.linux.org.uk (subscribers-only)
+S:	Maintained
+
 ARPD SUPPORT
 P:	Jonathan Layes
 L:	netdev@vger.kernel.org
@@ -688,12 +796,24 @@ M:	joel.becker@oracle.com
 L:	linux-kernel@vger.kernel.org
 S:	Supported
 
+CIRRUS LOGIC EP93XX ETHERNET DRIVER
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	netdev@vger.kernel.org
+S:	Maintained
+
 CIRRUS LOGIC GENERIC FBDEV DRIVER
 P:	Jeff Garzik
 M:	jgarzik@pobox.com
 L:	linux-fbdev-devel@lists.sourceforge.net (subscribers-only)
 S:	Odd Fixes
 
+CIRRUS LOGIC EP93XX OHCI USB HOST DRIVER
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	linux-usb-devel@lists.sourceforge.net
+S:	Maintained
+
 CIRRUS LOGIC CS4280/CS461x SOUNDDRIVER
 P:	Cirrus Logic Corporation (kernel 2.2 driver)
 M:	Cirrus Logic Corporation, Thomas Woller <twoller@crystal.cirrus.com>
@@ -1563,6 +1683,12 @@ P:	Deepak Saxena
 M:	dsaxena@plexity.net
 S:	Maintained
 
+INTEL IXP2000 ETHERNET DRIVER
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
+L:	netdev@vger.kernel.org
+S:	Maintained
+
 INTEL PRO/100 ETHERNET SUPPORT
 P:	John Ronciak
 M:	john.ronciak@intel.com
