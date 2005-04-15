From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [2.6 patch] drivers/net/wan/: possible cleanups
Date: Fri, 15 Apr 2005 18:49:56 +0100
Message-ID: <1113587392.11155.33.camel@localhost.localdomain>
References: <20050327143418.GE4285@stusta.de>
	 <1111941516.14877.325.camel@localhost.localdomain>
	 <20050414232028.GD20400@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050414232028.GD20400@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Gwe, 2005-04-15 at 00:20, Adrian Bunk wrote:
> On Sun, Mar 27, 2005 at 05:38:38PM +0100, Alan Cox wrote:
> > On Sul, 2005-03-27 at 15:34, Adrian Bunk wrote:
> > >   - syncppp.c: sppp_input
> > >   - syncppp.c: sppp_change_mtu
> > >   - z85230.c: z8530_dma_sync
> > >   - z85230.c: z8530_txdma_sync
> > 
> > Please leave the z85230 ones at least. They are an intentional part of
> > the external API for writing other 85230 card drivers.
> 
> If they are part of an API, why aren't the prototypes for them in any 
> header file?

They were once. I guess that got "tided" at some point, possibly long
ago even before submission.

z8530_dma_sync and txdma_sync set up the device in DMA mode, or in DMA
one direction only mode. 
