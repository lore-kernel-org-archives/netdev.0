From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Wed, 02 Mar 2011 19:16:55 +0100
Message-ID: <4D6E8997.4010001@trash.net>
References: <20110228171738.2cc8c9a0@nehalam>	 <20110302020610.GD1005@gandalf.sssup.it>	 <1299064667.2920.4.camel@edumazet-laptop> <20110302081108.689571d8@nehalam>	 <1299082728.2920.18.camel@edumazet-laptop> <1299087087.2920.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Fabio Checconi <fchecconi@gmail.com>,
	David Miller <davem@davemloft.net>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40045 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168Ab1CBSQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 13:16:59 -0500
In-Reply-To: <1299087087.2920.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 02.03.2011 18:31, schrieb Eric Dumazet:
> Le mercredi 02 mars 2011 =C3=A0 17:18 +0100, Eric Dumazet a =C3=A9cri=
t :
>> Le mercredi 02 mars 2011 =C3=A0 08:11 -0800, Stephen Hemminger a =C3=
=A9crit :
>>
>>> I put the iproute2 code into the repository in the experimental bra=
nch.
>>>
>>
>> Thanks
>>
>> It seems as soon as packets are dropped, qdisc is frozen (no more
>> packets dequeued)
>>
>> Hmm...
>>
>=20
> It seems class deletes are buggy.
>=20
> After one "tc class del dev $ETH classid 11:1 ..."
>=20
> a "tc -s -d qdisc show dev $ETH" triggers an Oops

What classes and filters did you have before issuing that command?
