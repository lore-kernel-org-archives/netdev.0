From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [RFT] e100 driver on ARM
Date: Wed, 28 Mar 2007 16:04:32 -0700
Message-ID: <460AF480.7050609@intel.com>
References: <44FC0261.6010807@garzik.org> <20060904123123.GB1285@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Russell King <rmk+lkml@arm.linux.org.uk>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31787 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965795AbXC1XEe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 19:04:34 -0400
In-Reply-To: <20060904123123.GB1285@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> On Mon, Sep 04, 2006 at 06:39:29AM -0400, Jeff Garzik wrote:
> 
>> 1) Does e100 driver work on ARM?
> 
> FWIW, e100 seems to work okay for me on an intel ixp2400 (xscale based)
> board, an ixp2850 (xscale based) board and an ixp2350 (xscale3 based)
> board.  ixp2350 works both with hardware coherency turned on (cpu
> snoops bus) and turned off (manual dma cache clean/invalidate as usual.)
> 
> As for the other ARM platforms that I'm interested in / have hardware
> for / maintain, the at91/ep93xx/pxa270 don't have PCI, and the other
> two (iop32x/iop33x) I can't test because I don't have such systems with
> e100 NICs, but I expect those would work, since they're both xscale
> based like the ixp2400, and the ixp2400 works.

I just got an iop342 board dropped on my lap. Once it's running, I'll make sure 
to make this the first thing to test.

Cheers,

Auke
