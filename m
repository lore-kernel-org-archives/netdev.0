From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: add a missing include in
 nf_conntrack_reasm.c
Date: Thu, 20 Jan 2011 20:57:23 +0100
Message-ID: <1295553443.2613.3.camel@edumazet-laptop>
References: <1295545997.2825.458.camel@edumazet-laptop>
	 <4D388A83.5020501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	KOVACS Krisztian <hidden@balabit.hu>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D388A83.5020501@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 20 janvier 2011 =C3=A0 20:18 +0100, Patrick McHardy a =C3=A9cr=
it :
> Am 20.01.2011 18:53, schrieb Eric Dumazet:
> > After commit ae90bdeaeac6b (netfilter: fix compilation when conntra=
ck is
> > disabled but tproxy is enabled) we have following warnings :
> >=20
> > net/ipv6/netfilter/nf_conntrack_reasm.c:520:16: warning: symbol
> > 'nf_ct_frag6_gather' was not declared. Should it be static?
> > net/ipv6/netfilter/nf_conntrack_reasm.c:591:6: warning: symbol
> > 'nf_ct_frag6_output' was not declared. Should it be static?
> > net/ipv6/netfilter/nf_conntrack_reasm.c:612:5: warning: symbol
> > 'nf_ct_frag6_init' was not declared. Should it be static?
> > net/ipv6/netfilter/nf_conntrack_reasm.c:640:6: warning: symbol
> > 'nf_ct_frag6_cleanup' was not declared. Should it be static?
> >=20
> > Fix this including net/netfilter/ipv6/nf_defrag_ipv6.h
> >=20
>=20
> I currently don't have access to all my trees, does this patch
> apply to 2.6.38 or just the current -rc?

I dont really understand the question.

Or do you mean 2.6.37 versus 2.6.38-rc1 ?

It's a minor correction anyway, not a stable candidate. It would be goo=
d
to push it for current (2.6.38)



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
