From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CONFIG_PACKET_MMAP should depend on MMU
Date: Mon, 09 Apr 2007 11:43:23 -0700 (PDT)
Message-ID: <20070409.114323.78734391.davem@davemloft.net>
References: <6d6a94c50704082001y5c13c865ic3d70217aba7d181@mail.gmail.com>
	<1176112223.17975.8.camel@roc-desktop>
	<20070409.095523.122833625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, waltje@uWalt.NL.Mugnet.ORG,
	aubreylee@gmail.com, netdev@vger.kernel.org, akpm@osdl.org,
	linux-kernel@vger.kernel.org
To: bryan.wu@analog.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753396AbXDISnZ@vger.kernel.org>
In-Reply-To: <20070409.095523.122833625.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Mon, 09 Apr 2007 09:55:23 -0700 (PDT)

> From: "Wu, Bryan" <bryan.wu@analog.com>
> Date: Mon, 09 Apr 2007 17:50:22 +0800
> 
> > On Mon, 2007-04-09 at 11:01 +0800, Aubrey Li wrote:
> > > The option CONFIG_PACKET_MMAP should depend on MMU.
> > > 
> > > Signed-off-by: Aubrey.Li <aubreylee@gmail.com>
> > > ---
> > >  net/packet/Kconfig |    2 +-
> > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/net/packet/Kconfig b/net/packet/Kconfig
> > > index 34ff93f..959c272 100644
> > > --- a/net/packet/Kconfig
> > > +++ b/net/packet/Kconfig
> > > @@ -17,7 +17,7 @@ config PACKET
> > > 
> > >  config PACKET_MMAP
> > >  	bool "Packet socket: mmapped IO"
> > > -	depends on PACKET
> > > +	depends on PACKET && MMU
> > >  	help
> > >  	  If you say Y here, the Packet protocol driver will use an IO
> > >  	  mechanism that results in faster communication.
> > 
> > Yeah, this is a bug found on blackfin arch and it is also for other
> > NOMMU arch. Is there any solution for this? We think Aubrey's idea
> > works.
> 
> I will apply this patch.

Actually I won't, the other comments in this thread make a lot
of sense, we should try to make it build and work just as we
do for other similar things on no-MMU.
