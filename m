From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix Micrel KSZ8842 Kconfig description
Date: Sun, 23 Aug 2009 19:49:44 -0700 (PDT)
Message-ID: <20090823.194944.212844649.davem@davemloft.net>
References: <4A8E78C1.20409@mocean-labs.com>
	<20090821104606.GA13440@rhlx01.hs-esslingen.de>
	<4A8E9BD3.1040107@mocean-labs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andi@lisas.de, netdev@vger.kernel.org
To: richard.rojfors.ext@mocean-labs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48211
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751276AbZHXCtc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2009 22:49:32 -0400
In-Reply-To: <4A8E9BD3.1040107@mocean-labs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Richard R=F6jfors <richard.rojfors.ext@mocean-labs.com>
Date: Fri, 21 Aug 2009 15:06:27 +0200

> Andreas Mohr wrote:
>> Hi,
>> On Fri, Aug 21, 2009 at 12:36:49PM +0200, Richard R=F6jfors wrote:
>>> Andreas Mohr wrote:
>>>> Hi,
>>>>
>>>> when doing a "make oldconfig" recently, non-descriptive item "Micr=
el
>>>> KSZ8842"
>>>> came up, and when I hit "?" to get more info, all I got was a
>>>> tight-lipped
>>>> "This platform driver is for Micrel KSZ8842 chip.".
>>> I see your pain
>> Thanks, and very fast reply too :)
>>=20
>>> Remove "PCI-based"
>>>
>>> This is a platform device, it is not PCI based.
>>> The KS8842 can sit behind PCI, ISA or VLB, this driver basically
>>> supports the ISA mappings.
>>>
>>> --Richard
>> OK, I had added that because manufacturer specifications seemed to
>> suggest
>> PCI use only. "platform device" should have been a warning sign I
>> guess...
>> Signed-off-by: Andreas Mohr <andi@lisas.de>
>=20
> Looks good to me
>=20
> Acked-by: Richard R=F6jfors <richard.rojfors.ext@mocean-labs.com>

Applied, thanks everyone.
