From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Tue, 13 Jan 2009 18:42:53 +0100
Message-ID: <200901131842.54688.arnd@arndb.de>
References: <20090107195052.GA24981@ovro.caltech.edu> <200901131733.04341.arnd@arndb.de> <20090113164007.GA7434@ovro.caltech.edu>
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
Received: from moutng.kundenserver.de ([212.227.126.187]:63211 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661AbZAMRnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 12:43:19 -0500
In-Reply-To: <20090113164007.GA7434@ovro.caltech.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 13 January 2009, Ira Snyder wrote:
> So do you program one channel of the DMA engine from the host side and
> another channel from the guest side?

Yes.

> I tried to avoid having the host program the DMA controller at all.
> Using the DMAEngine API on the guest did better than I could achieve by
> programming the registers manually. I didn't use chaining or any of the
> fancier features in my tests, though.

Our driver unfortunately does not use the DMA API, but it clearly
should. What this means in your case is that you would need to port
the freescale DMA engine driver to the host side, to operate on the
PCI device. Not sure about how specifically this would work on fsl
hardware, but it seems generally doable.

	Arnd <><
