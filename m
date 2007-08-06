From: Aurelien Jarno <aurelien@aurel32.net>
Subject: [PATCH 0/3] SSB support for BCM947xx CPUs
Date: Mon, 6 Aug 2007 17:04:01 +0200
Message-ID: <20070806150401.GA24308@hall.aurel32.net>
References: <20070805231910.GB13927@hall.aurel32.net> <200708061042.14722.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@vger.kernel.org, Felix Fietkau <nbd@openwrt.org>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hall.aurel32.net ([88.191.38.19]:33281 "EHLO hall.aurel32.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932844AbXHFPEE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 11:04:04 -0400
Content-Disposition: inline
In-Reply-To: <200708061042.14722.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 06, 2007 at 10:42:14AM +0200, Michael Buesch wrote:
> On Monday 06 August 2007, Aurelien Jarno wrote:
> > The patch below against 2.6.23-rc1-mm2 implements EXTIF timing 
> > initialization, currently marked as TODO.
> > 
> > It originally comes from the OpenWrt patches.
> > 
> > Cc: Felix Fietkau <nbd@openwrt.org>
> > Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>
> > 
> > --- a/drivers/ssb/driver_mipscore.c
> > +++ b/drivers/ssb/driver_mipscore.c
> 
> Please do a seperate file driver_extif.c to implement these functions
> and call it from the mipscore driver.
> Compilation can also depend on the mipscore kconfig option, so no
> additional kconfig is needed.

I have separated EXTIF functions into driver_extif.c and taken into
account your other comments. The new patchset is organized a bit
differently.


The following patches add a few features into the SSB EXTIF driver and
fix and improve the SSB Broadcom MIPS core driver, in order to correctly
support the BCM947xx CPUs.

They originally comes from the OpenWrt patches.

Patch #1: SSB EXTIF timing & serial port initialization
Patch #2: Use SSB EXTIF in SSB MIPS core driver
Patch #3: Add buswidth to SSB MIPS core flash driver

Cc: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>

-- 
  .''`.  Aurelien Jarno	            | GPG: 1024D/F1BCDB73
 : :' :  Debian developer           | Electrical Engineer
 `. `'   aurel32@debian.org         | aurelien@aurel32.net
   `-    people.debian.org/~aurel32 | www.aurel32.net
