From: Stefan Priebe <s.priebe@profihost.ag>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
Date: Fri, 09 Dec 2011 20:01:26 +0100
Message-ID: <4EE25B06.7010907@profihost.ag>
References: <4ED7C367.3070109@profihost.ag>	 <20111201182309.GA10686@infradead.org>	 <1322770844.2750.1.camel@edumazet-laptop>	 <CA+5PVA6kZkgYus4698Up8Q8uMTetCU2=DnTD0RpgXuHkJj6KKg@mail.gmail.com> <1322773527.2750.27.camel@edumazet-laptop> <4ED86B79.4060506@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Josh Boyer <jwboyer@gmail.com>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	Dave Chinner <david@fromorbit.com>, stable@vger.kernel.org,
	Greg KH <gregkh@suse.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server655-han.de-nserver.de ([85.158.177.45]:47712 "EHLO
	server655-han.de-nserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752818Ab1LITBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 14:01:25 -0500
In-Reply-To: <4ED86B79.4060506@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 02.12.2011 07:08, schrieb Stefan Priebe - Profihost AG:
> Am 01.12.2011 22:05, schrieb Eric Dumazet:
>> Le jeudi 01 d=C3=A9cembre 2011 =C3=A0 15:37 -0500, Josh Boyer a =C3=A9=
crit :
>>
>>> Did you mean f2c31e32bf2c31e32b378a665 ?
>>
>> Oh well, yes ;)
>>
>>>> But this patch needs some followup patches (some of them in David =
net
>>>> tree, not yet in Linus tree)
>>>
>>> 9de79c127cccecb11ae6a21ab1499e87aa222880 (net: fix potential neighb=
our
>>> race in dst_ifdown()) is in Linus' tree.  Which others are missing?
>>
>> Hmm
>>
>> Linus tree :
>>
>> commit 580da35a31f91a594f3090b7a2c39b85cb051a12
>> IB: Fix RCU lockdep splats
>>
>> David tree :
>>
>> commit 218fa90f072e4aeff9003d57e390857f4f35513e
>> ipv4: fix lockdep splat in rt_cache_seq_show
>>
>> commit f7e57044eeb1841847c24aa06766c8290c202583
>> sch_teql: fix lockdep splat
>>
Hi,

any news on that? Systems still crashing every now and then. 3.0.13 was=
=20
released today but i haven't seen any of them.

Thanks!

Stefan
