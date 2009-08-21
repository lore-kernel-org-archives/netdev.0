From: =?ISO-8859-1?Q?Richard_R=F6jfors?=
	<richard.rojfors.ext@mocean-labs.com>
Subject: Re: [PATCH] Fix Micrel KSZ8842 Kconfig description
Date: Fri, 21 Aug 2009 15:06:27 +0200
Message-ID: <4A8E9BD3.1040107@mocean-labs.com>
References: <20090821102033.GA26577@rhlx01.hs-esslingen.de> <4A8E78C1.20409@mocean-labs.com> <20090821104606.GA13440@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andreas Mohr <andi@lisas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av10-2-sn2.hy.skanova.net ([81.228.8.182]:41505 "EHLO
	av10-2-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754373AbZHUNeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 09:34:22 -0400
In-Reply-To: <20090821104606.GA13440@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Mohr wrote:
> Hi,
>=20
> On Fri, Aug 21, 2009 at 12:36:49PM +0200, Richard R=F6jfors wrote:
>> Andreas Mohr wrote:
>>> Hi,
>>>
>>> when doing a "make oldconfig" recently, non-descriptive item "Micre=
l KSZ8842"
>>> came up, and when I hit "?" to get more info, all I got was a tight=
-lipped
>>> "This platform driver is for Micrel KSZ8842 chip.".
>> I see your pain
>=20
> Thanks, and very fast reply too :)
>=20
>> Remove "PCI-based"
>>
>> This is a platform device, it is not PCI based.
>> The KS8842 can sit behind PCI, ISA or VLB, this driver basically =20
>> supports the ISA mappings.
>>
>> --Richard
>=20
> OK, I had added that because manufacturer specifications seemed to su=
ggest
> PCI use only. "platform device" should have been a warning sign I gue=
ss...
>=20
>=20
> Signed-off-by: Andreas Mohr <andi@lisas.de>

Looks good to me

Acked-by: Richard R=F6jfors <richard.rojfors.ext@mocean-labs.com>


>=20
> --- linux-2.6.31-rc6/drivers/net/Kconfig.orig	2009-08-21 12:00:31.000=
000000 +0200
> +++ linux-2.6.31-rc6/drivers/net/Kconfig	2009-08-21 12:41:48.00000000=
0 +0200
> @@ -1727,7 +1727,8 @@ config KS8842
>  	tristate "Micrel KSZ8842"
>  	depends on HAS_IOMEM
>  	help
> -	  This platform driver is for Micrel KSZ8842 chip.
> +	  This platform driver is for Micrel KSZ8842 / KS8842
> +	  2-port ethernet switch chip (managed, VLAN, QoS).
> =20
>  config KS8851
>         tristate "Micrel KS8851 SPI"
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

