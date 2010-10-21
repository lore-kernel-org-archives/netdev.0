From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 5/9] ipvs network name space aware
Date: Thu, 21 Oct 2010 13:26:54 +0200
Message-ID: <1287660414.6871.85.camel@edumazet-laptop>
References: <201010081317.04167.hans.schillstrom@ericsson.com>
	 <20101021111644.GA25555@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, ja@ssi.bg, wensong@linux-vs.org,
	daniel.lezcano@free.fr
To: Simon Horman <horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101021111644.GA25555@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 21 octobre 2010 =C3=A0 13:16 +0200, Simon Horman a =C3=A9crit =
:

> > @@ -2680,10 +2664,15 @@ static int ip_vs_genl_dump_services(struct =
sk_buff *skb,
> >  	int idx =3D 0, i;
> >  	int start =3D cb->args[0];
> >  	struct ip_vs_service *svc;
> > -
> > +	struct net *net =3D skb->sk->sk_net;
>=20
> skb->sk->sk_net needs CONFIG_NS_NET.
> Is your plan for IPVS to unconditionally depend on CONFIG_NS_NET?
> It would be nice to avoid that, but I fear it will be too messy.
>=20


struct net *net =3D sock_net(skb->sk);

is your friend ;)


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
