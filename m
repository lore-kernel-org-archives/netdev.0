From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Thu, 15 Jan 2009 08:54:00 -0800
Message-ID: <20090115165359.GA2230@ovro.caltech.edu>
References: <20090107195052.GA24981@ovro.caltech.edu> <200901131842.54688.arnd@arndb.de> <20090115001251.GA10745@ovro.caltech.edu> <200901151358.34250.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:33826 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407AbZAOQyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 11:54:02 -0500
Content-Disposition: inline
In-Reply-To: <200901151358.34250.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 01:58:33PM +0100, Arnd Bergmann wrote:
> On Thursday 15 January 2009, Ira Snyder wrote:
> 
> > The only problem with that is that you cannot route interrupts from the
> > DMA controller over PCI with the PowerPC core running. Which makes it
> > mostly useless for this case.
> 
> If the host supports MSI, you can simply program the DMA controller to
> write the correct message to the inbound address of the MSI interrupt
> controller!
> 
> All modern host systems should have MSI, as this is required by the
> PCIe specification, but it still somewhat limits the choice of your
> hosts.
> 

These are PCI boards, not PCIe. The host computers are all Pentium3-M
systems. I tried enabling MSI on the Freescale boards in the driver, by
calling pci_enable_msi() during probe(), and it failed. I'm pretty sure
I can't do MSI.

I'll keep thinking about how to manage the DMA. Feel free to toss around
any ideas you have, though.

Ira
