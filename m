From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH net-next] bcm63xx_enet: add support Broadcom BCM6345 Ethernet
Date: Thu, 13 Jun 2013 10:55:01 +0100
Message-ID: <CAGVrzcbBqdy+NnbV_TWWf=bigpbYqPXktCVVOFhtBgvFkCrWgA@mail.gmail.com>
References: <1371066785-17168-1-git-send-email-florian@openwrt.org>
 <20130613.014450.1434692343011842828.davem@davemloft.net> <CAGVrzcYE4VDWtL_Uj1DrkZ6GqX6ghqPAXPpyLptc6PGwReixSQ@mail.gmail.com>
 <20130613.022524.568792627006552244.davem@davemloft.net> <CAGVrzcaqbdLPcuL0m56aBLuG9ruaQ1p4JfTWZV9DJ4zSrNcXtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, ralf@linux-mips.org,
	John Crispin <blogic@openwrt.org>,
	Linux-MIPS <linux-mips@linux-mips.org>,
	mbizon <mbizon@freebox.fr>, jogo@openwrt.org,
	Kevin Cernekee <cernekee@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36058 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758589Ab3FMJzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:55:42 -0400
Received: by mail-pd0-f180.google.com with SMTP id 10so11122217pdi.11
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 02:55:41 -0700 (PDT)
In-Reply-To: <CAGVrzcaqbdLPcuL0m56aBLuG9ruaQ1p4JfTWZV9DJ4zSrNcXtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/6/13 Florian Fainelli <florian@openwrt.org>:
> 2013/6/13 David Miller <davem@davemloft.net>
>>
>> From: Florian Fainelli <florian@openwrt.org>
>> Date: Thu, 13 Jun 2013 09:58:34 +0100
>>
>> > 2013/6/13 David Miller <davem@davemloft.net>:
>> >> From: Florian Fainelli <florian@openwrt.org>
>> >> Date: Wed, 12 Jun 2013 20:53:05 +0100
>> >>
>> >>> +#ifdef BCMCPU_RUNTIME_DETECT
>> >>
>> >> I want the MIPS folks to fix this brain damange.
>> >>
>> >> This runtime detect thing is just a big mess in a header file
>> >> using hundreds of lines of CPP stuff to express what is fundamentally
>> >> a simple (albeit sizable) Kconfig dependency.
>> >
>> > The codebase supporting the Broadcom BCM63xx SoC supports about 6-7
>>
>> You don't need to explain it to me, I read the code and understand
>> what it's trying to accomplish.
>>
>> I reject the implementation of it, only.
>>

You have marked the patch as Rejected in patchwork, so what is the
right way to move on with this?
