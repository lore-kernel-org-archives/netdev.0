From: Michael Banck <mbanck@debian.org>
Subject: Re: Bug#380411: 3c59x broken after swsuspend
Date: Tue, 15 Aug 2006 15:16:16 +0200
Message-ID: <20060815131614.GA31799@localhost.localdomain>
References: <20060730002718.GA13889@nighthawk.chemicalconnection.dyndns.org> <20060730092512.GH8147@nancy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.theo.chemie.tu-muenchen.de ([129.187.122.133]:63378 "EHLO
	mx1.theo.chemie.tu-muenchen.de") by vger.kernel.org with ESMTP
	id S965107AbWHONQT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 09:16:19 -0400
To: 380411@bugs.debian.org, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060730092512.GH8147@nancy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 30, 2006 at 11:25:12AM +0200, maximilian attems wrote:
> sending bugreport to netdev.

Thanks.

> On Sun, 30 Jul 2006, Michael Banck wrote:
> 
> > Package: linux-2.6
> > Version: 2.6.17-4
> > 
> > after hibernate, my 3Com Corporation 3c556 Hurricane CardBus [Cyclone]
> > (rev 10) (3c59x driver) fails to come back up.

I just verfied that Suspend to RAM works fine.

> > And this is in dmesg:

There is one more line in front of that I missed last time:

    ACPI: PCI Interrupt 0000:00:0b.0[A] -> Link [LNKA] -> GSI
10 (level, low) -> IRQ 10
> > 3c59x: Donald Becker and others. www.scyld.com/network/vortex.html
> > 0000:00:0b.0: 3Com PCI 3c556 Laptop Tornado at c8830400.
> > eth1: New link status: Connected (0001)
> > *** EEPROM MAC address is invalid.
> > 3c59x: vortex_probe1 fails.  Returns -22
> > ACPI: PCI interrupt for device 0000:00:0b.0 disabled
> > 3c59x: probe of 0000:00:0b.0 failed with error -22

This additional line is also printed to the console if I unload the
module, suspend to ram, and then modprobe it some time after resume.


Michael
