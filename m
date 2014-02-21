From: Per Hurtig <per.hurtig@kau.se>
Subject: Re: [PATCH 1/1] net: tcp: RTO restart
Date: Fri, 21 Feb 2014 11:49:06 +0100
Message-ID: <1250EA19-2144-4AC2-A802-5B1989F74B80@kau.se>
References: <20140218181205.GA7780@kau.se> <50334B08-CD60-4C4C-9556-ACC758F75D7E@simula.no> <1392832907.18849.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andreas Petlund <apetlund@simula.no>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	=?windows-1252?Q?Anna_Brunstr=F6m?= <anna.brunstrom@kau.se>,
	Michael Welzl <michawe@ifi.uio.no>,
	=?windows-1252?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.38]:26736 "EHLO tiger.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754156AbaBUK7j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 05:59:39 -0500
In-Reply-To: <1392832907.18849.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 19 Feb 2014, at 19:01, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2014-02-19 at 18:17 +0100, Andreas Petlund wrote:
>> I=92ve applied and tested the patch on VMs with both 32 bit and 64 b=
it kernel.
>>=20
>> Acked-by: Andreas Petlund <apetlund@simula.no>
>> Tested-by: Andreas Petlund <apetlund@simula.no>
>=20
> Sure the patch applies, but what experimental results did you get ?
>=20
> My concern is that TCP_SKB_CB(skb)->when doesn't account for sojourn
> time in host queues (qdisc and device).=20
>=20

Correct me if I=92m wrong, but I was under the impression that the sojo=
urn was
accounted for in the RTT calculations, and therefore rather inappropria=
te to
be accounted for again? If this assumption is wrong, how would you prop=
ose that
we account for the sojourn time?

> Note : Missing documentation for this new sysctl.
>=20

Yes, this we completely missed. Will fix.

> This patch certainly cannot be applied as is.
>=20
> Thanks !
>=20
>=20

Thank you,
Per Hurtig
