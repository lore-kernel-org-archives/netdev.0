From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver fixes
Date: Mon, 15 Sep 2008 14:11:59 -0700 (PDT)
Message-ID: <20080915.141159.181213705.davem@davemloft.net>
References: <20080915.120917.36004302.davem@davemloft.net>
	<20080915201749.GB3994@havoc.gtf.org>
	<20080915.132716.267218808.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758570AbYIOVNq@vger.kernel.org>
In-Reply-To: <20080915.132716.267218808.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Mon, 15 Sep 2008 13:27:16 -0700 (PDT)

> I'll take another look at the queue and try to give you some
> more specific feedback.

	Thomas Bogendoerfer (1):
	      tulip: Fix dead 21041 ethernet after ifconfig down

Not a regression, that problem has been there forever.

	Adrian Bunk (1):
	      [netdrvr/usb] hso_create_bulk_serial_device(): fix a double free

This is a new driver in 2.6.27, so OK.

	Andrew Morton (1):
	      drivers/net/mlx4/alloc.c needs mm.h

Build bustage, so ok.

	Breno Leitao (1):
	      s2io: Fix enabling VLAN tag stripping at driver initialization

Not a 2.6.27 regression, 2.6.26 has this problem too.

	Chris Snook (1):
	      MAINTAINERS: add Atheros maintainer for atlx

Doc change, so fine I guess.

	David Fries (1):
	      [netdrvr] ne: Fix suspend and resume for ISA PnP cards.

Definitely not a 2.6.27 regression.

	Francois Romieu (1):
	      r8169: fix RxMissed register access

Has a bugzilla entry, etc., so OK.

	Hannes Hering (1):
	      ehea: Fix DLPAR memory handling

No kernel bugzilla, no regression list entry, no way.

	Krzysztof Halasa (1):
	      wan/hdlc_x25.c: fix a NULL dereference

Not a 2.6.27 regression, this problem has been there forever.

	Magnus Damm (2):
	      smc91x: fix nowait printout

This one is good but the commit message needs to be fixed up.
It references a raw SHA1 ID but does not give the commit message
header line as well, which is a requirement.

      smc91x: SMC_IO_SHIFT platform data support for default case

Ok, but needs commit header line text for referenced commit.

	Martin Gebert (1):
	      [netdrvr] au1000_eth: Spinlock initialisation fix

This problem has existed forever, not a 2.6.27 regression,
and therefore not appropriate.

	Mats Erik Andersson (1):
	      8139too: [cosmetic] fix incorrect register for flash-rom

Cosmetic, indeed.  Not appropriate for 2.6.27

	Matthew Wilcox (1):
	      [netdrvr] atl1e: Don't take the mdio_lock in atl1e_probe

This is just lockep noise, and definitely not a 2.6.27 regression
as far as I can tell.  So this one has to go.

	Sebastien Dugue (1):
	      ehea: fix phyp debugging typo

DEBUG build fix, not a regression, not appropriate.

	Takashi Iwai (1):
	      drivers/net/skfp/pmf.c: Use offsetof() macro

Cleanup, not appropriate.  The code is actually fine but
emits some warnings during the build.

	Vlad Yasevich (1):
	      bonding: Do not tx-balance some IPv6 packets on ALB/TLB bonds

Not a 2.6.27 regression, not appropriate.

	Yinghai Lu (1):
	      forcedeth: call restore mac addr in nv_shutdown path

This appears to fix an entry in the regression list, so OK.

	Yoichi Yuasa (1):
	      cs89x0: fix warning release_irq label

Warning fix, not appropriate for 2.6.27


So, as I said, the vast majority of this stuff is absolulte not
appropriate.  Most of it can totally wait for 2.6.28, and not
be merged now.

You can accelerate this process by making sure that every
commit message has a reference to the regression list entry
or a kernel bugzilla that the patch fixes.

So please fix up this patch queue and resubmit, thanks.
