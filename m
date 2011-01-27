From: =?UTF-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_mqprio: dont leak kernel
 memory
Date: Thu, 27 Jan 2011 11:17:00 +0000
Message-ID: <4D41542C.1000000@draigBrady.com>
References: <1296062517.2899.86.camel@edumazet-laptop>	 <1296063823.6115.37.camel@Joe-Laptop>	 <1296064190.2899.88.camel@edumazet-laptop> <1296064578.6115.39.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.slb.deg.dub.stisp.net ([84.203.253.98]:11557 "HELO
	mail1.slb.deg.dub.stisp.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754368Ab1A0LZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 06:25:23 -0500
In-Reply-To: <1296064578.6115.39.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/01/11 17:56, Joe Perches wrote:
> On Wed, 2011-01-26 at 18:49 +0100, Eric Dumazet wrote:
>> Le mercredi 26 janvier 2011 =C3=A0 09:43 -0800, Joe Perches a =C3=A9=
crit :
>>> I think the best style to use memset so that any
>>> possible struct padding is guaranteed to be zeroed.
>> We use the { 0 } style in net/sched,
>=20
> That's nice, but it's the wrong style.
> https://lkml.org/lkml/2010/12/15/63
>=20
>> and there is no padding in this
>> structure, I checked this point.
>=20
> That may be true right now for this particular
> structure, but that style is not future-proof.

I think {0,} is a valid init style, because the handling
of the initialization is special and overrides the point
mentioned in the link above.

cheers,
P=C3=A1draig.
