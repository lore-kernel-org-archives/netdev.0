From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv2 net-next 0/5] pktgen IPsec support
Date: Tue, 10 Dec 2013 09:19:09 +0800
Message-ID: <52A66C0D.4050409@windriver.com>
References: <1386323614-5077-1-git-send-email-fan.du@windriver.com> <20131209.195854.223825767831436997.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <steffen.klassert@secunet.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:44939 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab3LJBT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 20:19:28 -0500
In-Reply-To: <20131209.195854.223825767831436997.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8810=E6=97=A5 08:58, David Miller wrote:
> From: Fan Du<fan.du@windriver.com>
> Date: Fri, 6 Dec 2013 17:53:29 +0800
>
>> Hi, Dave/Steffen
>>
>> Current pktgen IPsec supports only transport/ESP combinnation,
>> and it's buggy before I fixed transformed IP header/length issue
>> a few days ago.
>>
>> This patchset enables user to do almost any IPsec transformation,
>> both transport/tunnel mode, and AH/ESP/IPcomp type.
>>
>> Below configuration has been tested, and using Wireshark could decry=
pt
>> out plain text in good formation without any checksum/auth errors:
>>
>> Mode/TYPE	AH	ESP
>> Transport	x	x
>> Tunnel		x	x
>>
>> ChangeLog
>> v2:
>>    Rebase patchset against newest net-next.
>>    Patch1: Remove adding rebundant empty line spotted by Sergei.
>>    Patch2: Use only one dst pointing into itself to save space.
>
> I don't like how you've arranged this.
>
> The existing mechanism might be used by someone, and in patch #1
> you just remove it.
>
> It's fixed, but so what?  It might useful for someone.


How it could be usable first and then useful for someone before my fix
9e921193884dd85b4cd68aa18598d8c2f9ad85b9
({pktgen, xfrm} Correct xfrm state lock usage when transforming)???

Do you really know what this fix does?

> You must make your changes such that existing setups still
> work, you can't just break things on people.
>

The broken things is the original patch, not this patchset,
any people try to use pktgen with IPsec enabled could spot it's not wor=
king.
and any up comping make-working patch won't break anything!


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
