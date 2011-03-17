From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: xtables: fix reentrancy
Date: Thu, 17 Mar 2011 12:45:23 +0100
Message-ID: <1300362323.3133.195.camel@edumazet-laptop>
References: <1300302005.3202.23.camel@edumazet-laptop>
	 <20110316.131648.15245216.davem@davemloft.net>
	 <1300358140.3133.117.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1103171231220.21558@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1103171231220.21558@ask.diku.dk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 17 mars 2011 =C3=A0 12:36 +0100, Jesper Dangaard Brouer a =C3=A9=
crit :
> Hi Eric,
>=20
> How critial is this bug fix?
>=20
> Should I apply this on my stable production kernels?
> (I'm preparing a 2.6.38 kernel for prod usage, eventhougt its just be=
en=20
> released, because I want your SFQ fixes...)

I would say the race is there, but probability must be very small, and
might need malicious iptables rules (with RETURN targets)

Especially in routers, where OUTPUT path is taken from softirq handler
anyway ;)

So dont worry at all, consider this as a cleanup :)


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
