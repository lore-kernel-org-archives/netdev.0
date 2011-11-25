From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [v4 PATCH 1/2] NETFILTER module xt_hmark, new target for HASH
 based fwmark
Date: Fri, 25 Nov 2011 15:36:20 +0100
Message-ID: <1322231780.2403.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AEE3@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hans Schillstrom <hans@schillstrom.com>, kaber@trash.net,
	pablo@netfilter.org, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans.schillstrom@ericsson.com
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AEE3@saturn3.aculab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 25 novembre 2011 =C3=A0 14:19 +0000, David Laight a =C3=A9c=
rit :
> > +	addr1 =3D (__force u32) ip6->saddr.s6_addr32[3];
> > +	addr2 =3D (__force u32) ip6->daddr.s6_addr32[3];
> ...
> > +	ports.v32 =3D * (__force u32 *) (skb->data + nhoff);
>=20
> Is this code even vaguely portable??

Yes it is.

> I suspect the 'ports' bit has serious endianness problems.

We dont care of endianness here, and we document it with the (__force
u32) cast.



> I'm also not sure whether linux guarantees the alignment
> of skb->data here.


It is guaranteed in whole linux stack.


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
