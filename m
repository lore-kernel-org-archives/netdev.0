From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: skge: PCI error cmd=0x117 status=0x22b0
Date: Fri, 14 Nov 2008 10:06:23 -0800
Message-ID: <20081114100623.7287d9ec@extreme>
References: <20081114153646.GB7172@fi.muni.cz>
	<20081114084209.0ee411fd@extreme>
	<20081114175507.GC7172@fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Kasprzak <kas@fi.muni.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54933 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754326AbYKNSG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 13:06:28 -0500
In-Reply-To: <20081114175507.GC7172@fi.muni.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Nov 2008 18:55:07 +0100
Jan Kasprzak <kas@fi.muni.cz> wrote:

> Stephen Hemminger wrote:
> : On Fri, 14 Nov 2008 16:36:46 +0100
> : Jan Kasprzak <kas@fi.muni.cz> wrote:
> : 
> : > 	Hello,
> : > 
> : > I have an ASUS M2R32-MVP board with the skge network card. From time to time
> : > the network freezes with the following message (this one taken from
> : > 2.6.27-rc7, another one added even with timing information at the end
> : > of this mail):
> : > 
> : > skge 0000:03:04.0: PCI error cmd=0x117 status=0x22b0
> : > skge 0000:03:04.0: unable to clear error (so ignoring them)
> : 
> : The device is getting a PCI master abort on a DMA.
> : Either, you have hardware issues, or there is a driver bug when accessing
> : a particular memory address.  Do you have 4G or more of memory?
> 
> 	Yes (I have written it in my previous mail) - I have 8 GB of RAM.
> Can - for example - a non-linear memory (i.e. the memory hole remapping)
> be a problem? IIRC, I have it set to "on" in my BIOS setup.
> 
> : Some motherboards are crap and don't actually allow DMA from high memory.
> 
> 	With 8 GB only half of my RAM is below the 32-bit barrier,
> so I guess if this was a problem, I would got this error more often
> (every second packet on average?).
> 
> 	OK, I will try to poke my HW vendor. Thanks,
> 
> -Yenya
> 

You could also try adjustments of iommu on kernel command line
(force, off, soft, etc). Andi Kleen might no more about this.
