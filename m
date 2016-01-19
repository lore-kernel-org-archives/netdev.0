From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: question about samsung/sxgbe/sxgbe_xpcs.c
Date: Tue, 19 Jan 2016 19:54:20 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1601191918470.2531@hadrien>
References: <alpine.DEB.2.10.1601191723250.2531@hadrien> <CAKocOOOFrEFLL0MWnn_bhBby8GeVH82A2wtaL9Tg9QTJC2Wprw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Julia Lawall <julia.lawall@lip6.fr>, bh74.an@samsung.com,
	ks.giri@samsung.com, vipul.pandya@samsung.com,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	shuahkh@osg.samsung.com
To: Shuah Khan <shuahkhan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKocOOOFrEFLL0MWnn_bhBby8GeVH82A2wtaL9Tg9QTJC2Wprw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 19 Jan 2016, Shuah Khan wrote:

> 2016-01-19 9:26 GMT-07:00 Julia Lawall <julia.lawall@lip6.fr>:
> > Hello,
> >
> > I was windering what is the purpose of the file
> > drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c
>
> From git log and comments, it appears this driver is for
> Samsung SoCs.
>
> >
> > I can't find anything that refers to it, and if I remove it from the
> > makefile:
> >
> > @@ -1,4 +1,4 @@
> >  obj-$(CONFIG_SXGBE_ETH) += samsung-sxgbe.o
> >  samsung-sxgbe-objs:= sxgbe_platform.o sxgbe_main.o sxgbe_desc.o \
> >                 sxgbe_dma.o sxgbe_core.o sxgbe_mtl.o  sxgbe_mdio.o \
> > -               sxgbe_ethtool.o sxgbe_xpcs.o $(samsung-sxgbe-y)
> > +               sxgbe_ethtool.o $(samsung-sxgbe-y)
> >
> > and then make clean and recompile, I see no bad effect.
> >
>
> What is the motivation for the experiment to remove it?
> This file probably gets used only on Samsung SoCs.

I just wondered.  I was looking at dependencies between networking files.
This one stands out because nothing is dependenton it, even the files it
is compiled with, and it doesn't contain the usual functions,
register_netdev, etc.

Thanks for the explanation.

julia
