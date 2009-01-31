From: Parag Warudkar <parag.lkml@gmail.com>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Fri, 30 Jan 2009 19:28:25 -0500 (EST)
Message-ID: <alpine.DEB.2.00.0901301924550.5056@parag-desktop>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901301506120.3150@localhost.localdomain> <alpine.DEB.2.00.0901301826490.5027@parag-desktop> <200901310059.17746.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:1690 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbZAaA2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 19:28:36 -0500
In-Reply-To: <200901310059.17746.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 31 Jan 2009, Rafael J. Wysocki wrote:

> >  00:1c.0 PCI bridge: Intel Corporation 631xESB/632xESB/3100 Chipset PCI Express Root Port 1 (rev 09)
> > -	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> > +	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
> >  	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
> >  	Latency: 0, Cache Line Size: 64 bytes
> >  	Bus: primary=00, secondary=0e, subordinate=0e, sec-latency=0
> 
> and the PCIe port driver may be at fault.
> 
> Can you try to remove the pci_save_state(dev) from pcie_port_suspend_late()
> and see if that helps?
> 

I assume you meant pcie_portdrv_suspend_late in 
drivers/pci/pcie/portdrv_pci.c - that one did not go well.

With that change machine refuses to suspend (comes back after attempting) 
and my keyboard goes dead.

Parag
