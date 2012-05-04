From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH 04/15] drivers/net: Do not free an IRQ if its request failed
Date: Fri, 4 May 2012 20:22:10 +0200
Message-ID: <CACRpkdaB+mAmo50uSDvVcq=V9_BF01-zu2WHUU+cc2WPU1NEXA@mail.gmail.com>
References: <1334867804-31942-1-git-send-email-lee.jones@linaro.org>
	<1334867804-31942-5-git-send-email-lee.jones@linaro.org>
	<4FA3E35B.3000604@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux@arm.linux.org.uk, linus.walleij@stericsson.com,
	arnd@arndb.de, netdev@vger.kernel.org, grant.likely@secretlab.ca,
	cjb@laptop.org, linux-arm-kernel@lists.infradead.org
To: Lee Jones <lee.jones@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:42793 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753875Ab2EDSWL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 14:22:11 -0400
Received: by gghe5 with SMTP id e5so505854ggh.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 11:22:10 -0700 (PDT)
In-Reply-To: <4FA3E35B.3000604@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 4, 2012 at 4:10 PM, Lee Jones <lee.jones@linaro.org> wrote:
> On 19/04/12 21:36, Lee Jones wrote:

>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_irq;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_disable_resources;
>> =A0 =A0 =A0 =A0}
>>
>> =A0 =A0 =A0 =A0retval =3D register_netdev(dev);
>
>
> Anything on this from the Net guys?

This was merged for 3.4-rc5, check:
https://lkml.org/lkml/2012/4/29/2

Linus Walleij
