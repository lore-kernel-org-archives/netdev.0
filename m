From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: "e100_probe: Error clearing wake event" when booting 2.6.27-rc1
Date: Fri, 8 Aug 2008 00:00:06 +0200
Message-ID: <200808080000.07156.rjw@sisk.pl>
References: <200808051730.27599.alessandro.guido@gmail.com> <200808052203.07815.rjw@sisk.pl> <200808070947.37534.jbarnes@virtuousgeek.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alessandro Guido <alessandro.guido@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pm list <linux-pm@lists.linux-foundation.org>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757753AbYHGV5x@vger.kernel.org>
In-Reply-To: <200808070947.37534.jbarnes@virtuousgeek.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, 7 of August 2008, Jesse Barnes wrote:
> On Tuesday, August 5, 2008 1:03 pm Rafael J. Wysocki wrote:
> > On Tuesday, 5 of August 2008, Alessandro Guido wrote:
> > > [please cc me on replies]
> > >
> > > I'm getting this error message when booting my laptop.
> > >
> > > The commit that causes this is:
> > >
> > > commit eb9d0fe40e313c0a74115ef456a2e43a6c8da72f
> > > Author: Rafael J. Wysocki <rjw@sisk.pl>
> > > Date:   Mon Jul 7 03:34:48 2008 +0200
> > >
> > >     PCI ACPI: Rework PCI handling of wake-up
> > >
> > > [very long commit message snipped]
> > >
> > > Should I ignore that?
> >
> > The message is harmless, but it exposes the problem that e100_probe()
> > should not use pci_enable_wake() for this purpose.
> >
> > The appended patch makes it use pci_pme_active() instead.
> 
> I can take the pci_pme_active bits, but the e100 stuff should go in through 
> Jeff probably.  Care to respin?

Sure, in replies to this message.

Thanks,
Rafael
