From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Thu, 15 Jan 2009 13:58:33 +0100
Message-ID: <200901151358.34250.arnd@arndb.de>
References: <20090107195052.GA24981@ovro.caltech.edu> <200901131842.54688.arnd@arndb.de> <20090115001251.GA10745@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Ira Snyder <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:56479 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754124AbZAOM6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 07:58:44 -0500
In-Reply-To: <20090115001251.GA10745@ovro.caltech.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 15 January 2009, Ira Snyder wrote:

> The only problem with that is that you cannot route interrupts from the
> DMA controller over PCI with the PowerPC core running. Which makes it
> mostly useless for this case.

If the host supports MSI, you can simply program the DMA controller to
write the correct message to the inbound address of the MSI interrupt
controller!

All modern host systems should have MSI, as this is required by the
PCIe specification, but it still somewhat limits the choice of your
hosts.

	Arnd <><
