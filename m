From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bcm63xx_enet: add support Broadcom BCM6345
 Ethernet
Date: Thu, 13 Jun 2013 02:25:24 -0700 (PDT)
Message-ID: <20130613.022524.568792627006552244.davem@davemloft.net>
References: <1371066785-17168-1-git-send-email-florian@openwrt.org>
	<20130613.014450.1434692343011842828.davem@davemloft.net>
	<CAGVrzcYE4VDWtL_Uj1DrkZ6GqX6ghqPAXPpyLptc6PGwReixSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org, blogic@openwrt.org,
	linux-mips@linux-mips.org, mbizon@freebox.fr, jogo@openwrt.org,
	cernekee@gmail.com
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38317 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756168Ab3FMJZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:25:28 -0400
In-Reply-To: <CAGVrzcYE4VDWtL_Uj1DrkZ6GqX6ghqPAXPpyLptc6PGwReixSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Thu, 13 Jun 2013 09:58:34 +0100

> 2013/6/13 David Miller <davem@davemloft.net>:
>> From: Florian Fainelli <florian@openwrt.org>
>> Date: Wed, 12 Jun 2013 20:53:05 +0100
>>
>>> +#ifdef BCMCPU_RUNTIME_DETECT
>>
>> I want the MIPS folks to fix this brain damange.
>>
>> This runtime detect thing is just a big mess in a header file
>> using hundreds of lines of CPP stuff to express what is fundamentally
>> a simple (albeit sizable) Kconfig dependency.
> 
> The codebase supporting the Broadcom BCM63xx SoC supports about 6-7

You don't need to explain it to me, I read the code and understand
what it's trying to accomplish.

I reject the implementation of it, only.

> No, the ifdefs are kept in the arch/mips/bcm63xx portions of the code
> specifically for that reason. The driver just needs to take into account a
> new set of platform_data properties to deal with this.

Fine, it's still terrible.
