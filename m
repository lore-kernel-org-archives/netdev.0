From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH] net: sh_eth: Add support of device tree probe
Date: Thu, 7 Feb 2013 13:48:44 +0900
Message-ID: <CABMQnVJ3jOYa2qi_cN1qzP=KQ+groCWWpbPndmisgWKR7=tvVQ@mail.gmail.com>
References: <1360116019-8870-1-git-send-email-horms+renesas@verge.net.au>
 <87pq0dg7ot.wl%kuninori.morimoto.gx@renesas.com> <CABMQnVLr9WqMWC6z3BuYyBvNSXM491VwrZ+DcKd3qGu0UN-G3Q@mail.gmail.com>
 <87wqukzyps.wl%kuninori.morimoto.gx@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Simon Horman <horms+renesas@verge.net.au>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:50043 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021Ab3BGEtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 23:49:16 -0500
Received: by mail-we0-f169.google.com with SMTP id t11so1760999wey.0
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 20:49:15 -0800 (PST)
In-Reply-To: <87wqukzyps.wl%kuninori.morimoto.gx@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Feb 7, 2013 at 10:42 AM, Kuninori Morimoto
<kuninori.morimoto.gx@renesas.com> wrote:
>
> Hi Iwamatsu-san
>
>> >> +Required properties:
>> >> +- compatible:                   "renesas,sh-eth";
>> >> +- interrupt-parent:             The phandle for the interrupt controller that
>> >> +                                services interrupts for this device.
>> >> +- reg:                          Offset and length of the register set for the
>> >> +                                device.
>> >> +- interrupts:                   Interrupt mapping for the sh_eth interrupt
>> >> +                                sources (vector id).
>> >> +- phy-mode:              String, operation mode of the PHY interface.
>> >> +- sh-eth,edmac-endian:          String, endian of sh_eth dmac.
>> >
>> > I believe endian is only little/big.
>> > It can be "bool" settings, not "string" ?
>> >
>>
>> If we use bool , we may use this as "sh-eth,edmac-endian-big" or
>> sh-eth,edmac-endian-little.
>> Or we define big-endian, and when using big-endian, we specify this.
>> Either way is okay.
>
> Sorry, if it means
>
> "we define big-endian as default settings,
> and user can select little-endian by using sh-eth,edmac-little-endian"
>
> then, it is nice.
> Then, it can be "Option" properties.

OK, I will update.

>
>> >> +- sh-eth,endian:                String, endian of sh_eth dmac.
>> >
>> > Is this really used it in this driver ?
>> >
>>
>> Yes. In many cases, this uses little-endian, but user may specify
>> big-endian, I think.
>
> I meant that I could find "sh-eth,edmac-endian" operation,
> but, couldn't find "sh-eth,endian" operation on sh_eth_parse_dt()
> and on Example either.
>

OK,I will remove this sentence.

Thanks,
  Nobuhiro
-- 
Nobuhiro Iwamatsu
