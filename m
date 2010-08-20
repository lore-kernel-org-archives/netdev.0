From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] netfilter: fix the hash random initializing race
Date: Fri, 20 Aug 2010 18:26:40 +0200
Message-ID: <1282321600.2484.297.camel@edumazet-laptop>
References: <1282320404-2948-1-git-send-email-xiaosuo@gmail.com>
	 <1282321023.2484.285.camel@edumazet-laptop>
	 <alpine.LSU.2.01.1008201819080.7497@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1008201819080.7497@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 20 ao=C3=BBt 2010 =C3=A0 18:20 +0200, Jan Engelhardt a =C3=A9=
crit :
> On Friday 2010-08-20 18:17, Eric Dumazet wrote:
> >> +	if (unlikely(!nf_conntrack_hash_rnd)) {
> >> +		unsigned int rand;
> >> +
> >> +		/* Why not initialize nf_conntrack_rnd in a "init()" function ?
> >> +		 * Because there isn't enough entropy when system initializing,
> >> +		 * and we initialize it as late as possible. */
> >
> >This patch is fine but a fine multi line comment is :
> >	/* Some
> >	 * fine
> >	 * comment
> >	 */
>=20
> Actually,
>=20
> 	/*
> 	 * Some
> 	 */
>=20
> But that's in CodingStyle already. Always a good read, even if reread=
=2E

Sorry, I documented David S. Miller choice, or else I would have
mentioned CodingStyle :)

	/* Some
	 * fine
	 * comment
	 */

And it really is better ;)



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
