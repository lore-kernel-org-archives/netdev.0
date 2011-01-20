From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: add a missing include in nf_conntrack_reasm.c
Date: Thu, 20 Jan 2011 21:01:42 +0100
Message-ID: <4D3894A6.3040002@trash.net>
References: <1295545997.2825.458.camel@edumazet-laptop>	 <4D388A83.5020501@trash.net> <1295553443.2613.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	KOVACS Krisztian <hidden@balabit.hu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295553443.2613.3.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 20.01.2011 20:57, schrieb Eric Dumazet:
> Le jeudi 20 janvier 2011 =C3=A0 20:18 +0100, Patrick McHardy a =C3=A9=
crit :
>> Am 20.01.2011 18:53, schrieb Eric Dumazet:
>>> After commit ae90bdeaeac6b (netfilter: fix compilation when conntra=
ck is
>>> disabled but tproxy is enabled) we have following warnings :
>>>
>>> net/ipv6/netfilter/nf_conntrack_reasm.c:520:16: warning: symbol
>>> 'nf_ct_frag6_gather' was not declared. Should it be static?
>>> net/ipv6/netfilter/nf_conntrack_reasm.c:591:6: warning: symbol
>>> 'nf_ct_frag6_output' was not declared. Should it be static?
>>> net/ipv6/netfilter/nf_conntrack_reasm.c:612:5: warning: symbol
>>> 'nf_ct_frag6_init' was not declared. Should it be static?
>>> net/ipv6/netfilter/nf_conntrack_reasm.c:640:6: warning: symbol
>>> 'nf_ct_frag6_cleanup' was not declared. Should it be static?
>>>
>>> Fix this including net/netfilter/ipv6/nf_defrag_ipv6.h
>>>
>>
>> I currently don't have access to all my trees, does this patch
>> apply to 2.6.38 or just the current -rc?
>=20
> I dont really understand the question.
>=20
> Or do you mean 2.6.37 versus 2.6.38-rc1 ?

Right, that was a typo.

> It's a minor correction anyway, not a stable candidate. It would be g=
ood
> to push it for current (2.6.38)

Applied, thanks.

I'll push this together with a bunch of other fixes to Dave later tonig=
ht.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
