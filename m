From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH, RFT] bcm43xx: Busting the 1G limit
Date: Mon, 19 Jun 2006 22:43:08 +0200
Message-ID: <200606192243.09039.mb@bu3sch.de>
References: <200606171928.08155.mb@bu3sch.de> <1150730630.9048.2.camel@athena.fprintf.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:60892
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932088AbWFSUoQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 16:44:16 -0400
To: Daniel Gryniewicz <dang@fprintf.net>
In-Reply-To: <1150730630.9048.2.camel@athena.fprintf.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 19 June 2006 17:23, Daniel Gryniewicz wrote:
> On Sat, 2006-06-17 at 19:28 +0200, Michael Buesch wrote:
> > Hi,
> > 
> > This patch adds full 32-bit and 64-bit DMA support
> > to the bcm43xx driver. Well, it _should_ do this. I can
> > not test it, as I don't have a machine to trigger the 1G
> > limit.
> > The 1G limit should be exploitable on an AMD64 machine
> > with more than 1G RAM.
> > 
> > Please test and report, if it works or not. In the
> > case of "works not", please provide full dmesg log.
> > 
> > Note that I am not sure which cards actually support
> > full 32-bit or even 64-bit mode. Older cards might still
> > only support 30-bit DMA.
> 
> Hi.
> 
> I tried this on both 2.6.17-rc6 and on wireless-dev, and got pretty much
> the same panic on both (modulo locking).  My box is a turion with 2 GB
> of ram and a BCM4318.  Here's the panic from wireless-dev:
> 
> Unable to handle kernel NULL pointer dereference at 0000000000000020
> RIP:
> <ffffffff88104f24>{:bcm43xx:bcm43xx_dma_handle_xmitstatus+436}

I am still not absolutely sure where this oops comes from.
Could you remove at least 1G of your RAM and retry?

-- 
Greetings Michael.
