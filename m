From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/5] netdev: bfin_mac: push settings
 to platform resources
Date: Sun, 24 Oct 2010 19:40:31 -0400
Message-ID: <AANLkTik5_a6t5xJ9TWJf37UCL52O02nAQY4YwB6mgnQx@mail.gmail.com>
References: <1287727161-24671-1-git-send-email-vapier@gentoo.org> <20101024.161722.258113499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46214 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996Ab0JXXkx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 19:40:53 -0400
Received: by wyf28 with SMTP id 28so2758654wyf.19
        for <netdev@vger.kernel.org>; Sun, 24 Oct 2010 16:40:52 -0700 (PDT)
In-Reply-To: <20101024.161722.258113499.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 24, 2010 at 19:17, David Miller wrote:
> From: Mike Frysinger <vapier@gentoo.org>
>> From: Sonic Zhang <sonic.zhang@analog.com>
>>
>> Move all the pin settings out of the Kconfig and into the platform
>> resources (MII vs RMII). =C2=A0This clean up also lets us push out t=
he
>> phy settings so that board porters may control the layout.
>
> You'll have to approach this differently.
>
> The platform specific bfin_mac changes have to be in place
> before this change goes in.
>
> Not the other way around.
>
> Right now, in fact, there is only one blackfin board support
> file that has the bfin_mii_bus_platform_data bits, but that's
> not even going to compile because this patch being discussed
> isn't applied.
>
> You guys really have to sort this stuff out so that things
> get staged in cleanly and the tree compiles properly commit
> to commit.

and i have the Blackfin changes waiting for you to merge this patch.
i can squash them into this change and have you merge the result, or i
can merge it.  i dont really care either way.
-mike
