From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Thu, 15 Jan 2009 11:21:29 -0800
Message-ID: <20090115192129.GB9091@ovro.caltech.edu>
References: <20090107195052.GA24981@ovro.caltech.edu> <200901151358.34250.arnd@arndb.de> <20090115165359.GA2230@ovro.caltech.edu> <200901151853.52202.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:44918 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765461AbZAOTVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 14:21:31 -0500
Content-Disposition: inline
In-Reply-To: <200901151853.52202.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 06:53:51PM +0100, Arnd Bergmann wrote:
> On Thursday 15 January 2009, Ira Snyder wrote:
> > 
> > These are PCI boards, not PCIe. The host computers are all Pentium3-M
> > systems. I tried enabling MSI on the Freescale boards in the driver, by
> > calling pci_enable_msi() during probe(), and it failed. 
> 
> That doesn't really mean anything, just that the PCI endpoint doesn't
> announce its capability to do MSI in the config space, or that it
> does not have an interrupt line. Since you basically implement the
> device on the FSL board, you should also be able to define the interrupt
> capabilities by writing to the config space.
> 
> Do you know what kind of chipset the host uses? It should be fairly
> simple to find out whether or not it can do MSI.
> 

I have another question for you Arnd.

What did you use as the host and guest drivers when you ran virtio over
PCI? Did you use two unmodified instances of virtio_net (one on host,
one on guest) for networking, or did you write new virtio drivers for
those? How about for virtio_console (if you ran it at all).

Thanks again,
Ira
