From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/5] netfilter updates for net-next (upcoming 3.5),
 batch 2
Date: Wed, 09 May 2012 15:04:21 +0200
Message-ID: <1336568661.21775.20.camel@edumazet-laptop>
References: <1336563188-6720-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: pablo@netfilter.org, Deng-Cheng Zhu <dczhu@mips.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1336563188-6720-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 09 mai 2012 =C3=A0 13:33 +0200, pablo@netfilter.org a =C3=A9=
crit :
> From: Pablo Neira Ayuso <pablo@netfilter.org>
>=20
> Hi David,
>=20
> This is a second batch of netfilter updates for net-next, they contai=
n:
>=20
> * The new HMARK target from Hans Schillstrom. It took lots of spins
>   to get this into shape. This target provides a hash-based packet / =
flow
>   pre-classifier for iptables that can be used to distribute packets
>   / flows between uplinks and backend servers. It provides to modes, =
one
>   that relies on conntrack, and one that is stateless per-packet.

It seems this might be a good base for Deng-Cheng Zhu concerns.

(subject on netdev : RPS: Sparse connection optimizations )




--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
