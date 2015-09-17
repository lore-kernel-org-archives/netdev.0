From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: smc91x: convert pxa dma to dmaengine
Date: Thu, 17 Sep 2015 22:00:37 +0100
Message-ID: <20150917210037.GT21084@n2100.arm.linux.org.uk>
References: <1441913164-3785-1-git-send-email-robert.jarzmik@free.fr>
 <20150915.162414.1153837609419205002.davem@davemloft.net>
 <87a8smsntp.fsf@belgarion.home>
 <20150917.133722.634502765225590262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robert.jarzmik@free.fr, nico@fluxnic.net, arnd@arndb.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150917.133722.634502765225590262.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 17, 2015 at 01:37:22PM -0700, David Miller wrote:
> From: Robert Jarzmik <robert.jarzmik@free.fr>
> Date: Wed, 16 Sep 2015 11:41:54 +0200
> 
> > David Miller <davem@davemloft.net> writes:
> > 
> >> From: Robert Jarzmik <robert.jarzmik@free.fr>
> >> Date: Thu, 10 Sep 2015 21:26:04 +0200
> >>
> >>> Convert the dma transfers to be dmaengine based, now pxa has a dmaengine
> >>> slave driver. This makes this driver a bit more PXA agnostic.
> >>> 
> >>> The driver was tested on pxa27x (mainstone) and pxa310 (zylonite),
> >>> ie. only pxa platforms.
> >>> 
> >>> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> >>> Cc: Russell King <linux@arm.linux.org.uk>
> >>> Cc: Arnd Bergmann <arnd@arndb.de>
> >>> ---
> >>> This has potential to break other platform such as Neponset, Idp,
> >>> halibut and qsd8x50, so I added Russell and Arnd as they were discussing
> >>> smc91x support last February.
> >>
> > 
> >> Is someone testing whether such platforms break or not?  I'm waiting for
> >> that before I consider applying this patch.
> > 
> > My understanding is that Russell is the only one left testing them, or at least
> > he was the only one complaining about a breakage lately on neponset.
> > 
> > I can wait several weeks for Russell to have a bit of time to try : I know it
> > will compile correctly at least for neponset, and I know almost all the code is
> > under #ifdef CONFIG_ARCH_PXA. And still I would feel far more comfortable if it
> > was tested, just as you.
> 
> Oh well, I've waited long enough.... patch applied, thanks.

Well, I'm unlikely to get around to testing on the neponset any time
in the next month, and I don't think there's much that would go wrong
as a result of these changes: neponset doesn't use any of this DMA
code.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
