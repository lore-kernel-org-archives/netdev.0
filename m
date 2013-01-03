From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH V2] bgmac: driver for GBit MAC core on BCMA bus
Date: Thu, 3 Jan 2013 18:38:11 +0100
Message-ID: <CACna6rzOm3+NihpzMdsQUFfLXy+gZmhtatzjU3+EiujOvndW-A@mail.gmail.com>
References: <1357232192-32634-1-git-send-email-zajec5@gmail.com>
	<1357234105.4740.10.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:55334 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444Ab3ACRiM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 12:38:12 -0500
Received: by mail-ob0-f175.google.com with SMTP id vb8so13827229obc.20
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2013 09:38:12 -0800 (PST)
In-Reply-To: <1357234105.4740.10.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/1/3 Joe Perches <joe@perches.com>:
> On Thu, 2013-01-03 at 17:56 +0100, Rafa=C5=82 Mi=C5=82ecki wrote:
>> BCMA is a Broadcom specific bus with devices AKA cores. All recent B=
CMA
>> based SoCs have gigabit ethernet provided by the GBit MAC core. This
>> patch adds driver for such a cores registering itself as a netdev. I=
t
>> has been tested on a BCM4706 and BCM4718 chipsets.
>
> Just some style trivia if you want to clean it up later.
>
>> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/eth=
ernet/broadcom/bgmac.c
> []
>> +             bgmac_err(bgmac, "Timeout suspending DMA TX ring 0x%X =
(BGMAC_DMA_TX_STAT: 0x%08X)\n",
>> +                       ring->mmio_base, val);
>
> It'd be nicer if you always used this wrapping style.

My bad, sorry! Waiting for Francois comments before submitting next ver=
sion.

--=20
Rafa=C5=82
