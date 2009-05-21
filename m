From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [2.6.30] e1000e: pci_enable_pcie_error_reporting failed 0xfffffffb
Date: Thu, 21 May 2009 22:32:23 +0200
Message-ID: <200905212232.24232.rjw@sisk.pl>
References: <200905141312.35945.elendil@planet.nl> <200905212200.14375.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	linux-pm@lists.linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Linux PCI <linux-pci@vger.kernel.org>
To: Frans Pop <elendil@planet.nl>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <200905212200.14375.elendil@planet.nl>
Content-Disposition: inline
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 21 May 2009, Frans Pop wrote:
> On Thursday 14 May 2009, Frans Pop wrote:
> > With 2.6.30-rc[45] I'm always seeing this error while resuming from STR
> > on my HP 2510p notebook:
> >
> >   e1000e 0000:00:19.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
> > ! e1000e 0000:00:19.0: pci_enable_pcie_error_reporting failed 0xfffffffb
> >   e1000e 0000:00:19.0: setting latency timer to 64 
> >   e1000e 0000:00:19.0: wake-up capability disabled by ACPI
> >   e1000e 0000:00:19.0: PME# disabled
> >   e1000e 0000:00:19.0: wake-up capability disabled by ACPI
> >   e1000e 0000:00:19.0: PME# disabled
> >   e1000e 0000:00:19.0: irq 26 for MSI/MSI-X
> >
> > The error only shows up during resume, not during normal boot.
> >
> > With 2.6.29 the error is not present. Is this something that should be
> > looked into? Networking still comes up normally.
> 
> I'm still seeing this with 2.6.30-rc6. Should I just ignore it or is it an
> indication of a problem/regression?

Sorry for the lack of response.

I'm not sure if this is a symptom of a regression.  It looks like the driver
has become more verbose.

Thanks,
Rafael
