From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH net-next] bcm63xx_enet: add support Broadcom BCM6345 Ethernet
Date: Thu, 13 Jun 2013 10:49:18 +0100
Message-ID: <CAGVrzcaqbdLPcuL0m56aBLuG9ruaQ1p4JfTWZV9DJ4zSrNcXtg@mail.gmail.com>
References: <1371066785-17168-1-git-send-email-florian@openwrt.org>
 <20130613.014450.1434692343011842828.davem@davemloft.net> <CAGVrzcYE4VDWtL_Uj1DrkZ6GqX6ghqPAXPpyLptc6PGwReixSQ@mail.gmail.com>
 <20130613.022524.568792627006552244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, ralf@linux-mips.org,
	John Crispin <blogic@openwrt.org>,
	Linux-MIPS <linux-mips@linux-mips.org>,
	mbizon <mbizon@freebox.fr>, jogo@openwrt.org,
	Kevin Cernekee <cernekee@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:64049 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758376Ab3FMJuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:50:01 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq13so4804874pab.25
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 02:50:00 -0700 (PDT)
In-Reply-To: <20130613.022524.568792627006552244.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/6/13 David Miller <davem@davemloft.net>
>
> From: Florian Fainelli <florian@openwrt.org>
> Date: Thu, 13 Jun 2013 09:58:34 +0100
>
> > 2013/6/13 David Miller <davem@davemloft.net>:
> >> From: Florian Fainelli <florian@openwrt.org>
> >> Date: Wed, 12 Jun 2013 20:53:05 +0100
> >>
> >>> +#ifdef BCMCPU_RUNTIME_DETECT
> >>
> >> I want the MIPS folks to fix this brain damange.
> >>
> >> This runtime detect thing is just a big mess in a header file
> >> using hundreds of lines of CPP stuff to express what is fundamentally
> >> a simple (albeit sizable) Kconfig dependency.
> >
> > The codebase supporting the Broadcom BCM63xx SoC supports about 6-7
>
> You don't need to explain it to me, I read the code and understand
> what it's trying to accomplish.
>
> I reject the implementation of it, only.
>
> > No, the ifdefs are kept in the arch/mips/bcm63xx portions of the code
> > specifically for that reason. The driver just needs to take into account a
> > new set of platform_data properties to deal with this.
>
> Fine, it's still terrible.

We are in the slow process to switch to Device Tree to precisely
eliminate all of this (although not everyone agrees yet on the
details). Hopefully you should not see such things in the future.

Thanks
