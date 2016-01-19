From: Shuah Khan <shuahkhan@gmail.com>
Subject: Re: question about samsung/sxgbe/sxgbe_xpcs.c
Date: Tue, 19 Jan 2016 11:18:12 -0700
Message-ID: <CAKocOOOFrEFLL0MWnn_bhBby8GeVH82A2wtaL9Tg9QTJC2Wprw@mail.gmail.com>
References: <alpine.DEB.2.10.1601191723250.2531@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	shuahkh@osg.samsung.com
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1601191723250.2531@hadrien>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-01-19 9:26 GMT-07:00 Julia Lawall <julia.lawall@lip6.fr>:
> Hello,
>
> I was windering what is the purpose of the file
> drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c

>From git log and comments, it appears this driver is for
Samsung SoCs.

>
> I can't find anything that refers to it, and if I remove it from the
> makefile:
>
> @@ -1,4 +1,4 @@
>  obj-$(CONFIG_SXGBE_ETH) += samsung-sxgbe.o
>  samsung-sxgbe-objs:= sxgbe_platform.o sxgbe_main.o sxgbe_desc.o \
>                 sxgbe_dma.o sxgbe_core.o sxgbe_mtl.o  sxgbe_mdio.o \
> -               sxgbe_ethtool.o sxgbe_xpcs.o $(samsung-sxgbe-y)
> +               sxgbe_ethtool.o $(samsung-sxgbe-y)
>
> and then make clean and recompile, I see no bad effect.
>

What is the motivation for the experiment to remove it?
This file probably gets used only on Samsung SoCs.

thanks,
-- Shuah
