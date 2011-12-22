From: Michal Simek <monstr@monstr.eu>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Thu, 22 Dec 2011 09:05:13 +0100
Message-ID: <4EF2E4B9.4040504@monstr.eu>
References: <4EF1EC28.90008@monstr.eu>		<1324483144.2301.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>		<1324487504.2301.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <20111221.155520.1406613141134089105.davem@davemloft.net>	 <4EF2E102.7030008@monstr.eu> <1324540651.2621.44.camel@edumazet-laptop>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, john.williams@petalogix.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51092 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816Ab1LVIFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 03:05:16 -0500
Received: by eekc4 with SMTP id c4so8198187eek.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 00:05:14 -0800 (PST)
In-Reply-To: <1324540651.2621.44.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 08:49 +0100, Michal Simek a =C3=
=A9crit :
>> David Miller wrote:
>>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>> Date: Wed, 21 Dec 2011 18:11:44 +0100
>>>
>>>> [PATCH net-next] net: relax rcvbuf limits
>>>>
>>>> skb->truesize might be big even for a small packet.
>>>>
>>>> Its even bigger after commit 87fb4b7b533 (net: more accurate skb
>>>> truesize) and big MTU.
>>>>
>>>> We should allow queueing at least one packet per receiver, even wi=
th a
>>>> low RCVBUF setting.
>>>>
>>>> Reported-by: Michal Simek <monstr@monstr.eu>
>>>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>>> Applied to net-next, although I was tempted to put it into net.
>>>
>>> We may end up backporting this into -stable at some point, we'll
>>> see.
>> Yes, it works. Thanks Eric.
>>
>> I hope that this patch will be in v3.2.
>>
>=20
> Thanks for testing !
>=20
> I overlooked fact that commit 87fb4b7b533 was already in 3.2, so yes,=
 we
> probably can push this to 3.2

great.

> (By the way, busybox ping probably doesnt work on 3.1 kernel with a
> MTU=3D9000 non copybreak driver, so its not a clear 3.2 regression)

good to know.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/=
fdt/
Microblaze U-BOOT custodian
