From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter/IPv6: initialize TOS field in REJECT target
 module
Date: Fri, 6 May 2011 12:45:12 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1105061245070.25306@obet.zrqbmnf.qr>
References: <1303461461.3134.15.camel@edumazet-laptop>  <4DB61C2C.7060508@netfilter.org> <1303781180.2874.13.camel@nausicaa>  <20110425.221744.226775617.davem@davemloft.net>  <1303795522.6010.5.camel@nausicaa>  <4DB6E607.6000303@netfilter.org>
 <1304670430.6581.45.camel@nexus.oss.ntt.co.jp> <4DC3CFAD.8020305@netfilter.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Fernando_Luis_V=C3=A1zquez_Cao?= <fernando@oss.ntt.co.jp>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4DC3CFAD.8020305@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 2011-05-06 12:38, Pablo Neira Ayuso wrote:

>On 06/05/11 10:27, Fernando Luis V=C3=A1zquez Cao wrote:
>> On Tue, 2011-04-26 at 17:34 +0200, Pablo Neira Ayuso wrote:
>>> On 26/04/11 07:25, Fernando Luis Vazquez Cao wrote:
>>>> Pablo, could you pull in the two patches below? They have already =
been
>>>> acked by Eric. It would be great it we could get them merged for t=
he
>>>> next -rc and stable releases.
>>>>
>>>> [PATCH] netfilter/IPv6: fix DSCP mangle code
>>>> [PATCH] netfilter/IPv6: initialize TOS field in REJECT target modu=
le
>>>
>>> Patrick is the primary link to take patches, I'm including him in t=
his
>>> CC. If he experiences any problem, I'll make sure that these hit -r=
c, so
>>> never mind.
>>=20
>> It seems that the two patches above did not make it into 2.6.39-rc6.=
 Any
>> chance we can get them merged before 2.6.39 is released?
>
>I'll pick them and push them to davem by monday. Thanks!

Also revert a2361c8735e07322023aedc36e4938b35af31eb0 please.


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
