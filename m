From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] netfilter: ipt_CLUSTERIP: remove "no conntrack!"
Date: Thu, 13 Jan 2011 15:39:39 +0100
Message-ID: <1294929579.3570.163.camel@edumazet-laptop>
References: <4D2E1A74.5080102@netfilter.org>
	 <1294917210.3570.48.camel@edumazet-laptop> <4D2EE09A.1010409@netfilter.org>
	 <1294918365.3570.56.camel@edumazet-laptop> <4D2EE80B.6010707@netfilter.org>
	 <1294925915.3570.87.camel@edumazet-laptop>
	 <alpine.LNX.2.01.1101131502240.25211@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1101131502240.25211@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 13 janvier 2011 =C3=A0 15:02 +0100, Jan Engelhardt a =C3=A9cri=
t :
> On Thursday 2011-01-13 14:38, Eric Dumazet wrote:
>=20
> >Le jeudi 13 janvier 2011 =C3=A0 12:54 +0100, Pablo Neira Ayuso a =C3=
=A9crit :
> >
> >> But printing this does not provide any useful information. The fir=
st
> >> packet that does not belong to the cluster node that has received =
the
> >> packet, or the first invalid packet, will trigger this.
> >>=20
> >> Moreover, this confuses users since they can do nothing if they re=
ceive
> >> this message.
> >>=20
> >> Moreover, this target should be supersedes by the cluster match, w=
hich
> >> has been there for quite some time (it's also more flexible).
> >
> >Now you mentioned it, cluster match is not as flexible right now,
> >its hashing is on source_ip only.
>=20
> I think in that case, xt_cluster should be improved rather
> than an old module.

Amen

We should not improve IPv4 support then, I see.

My customers use this old module, and upgrading to xt_cluster is not an
option.

Should we discuss this forever or fix it ?

In the end, people are forced to add useless iptables rule to DROP
INVALID packets before entering ipt_CLUSTERIP, after googling or
eventually asking to experts.

Last time this was discussed, this went nowhere :

http://www.spinics.net/lists/netfilter/msg48676.html

Come on guys, we can do it, dont be afraid.

A non rate limited printk() in kernel is forbidden, especially in
network stack.

Then, cluster match can be improved, I am sure you already have a patch
for it.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
