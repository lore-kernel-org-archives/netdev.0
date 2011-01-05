From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netfilter: fix the race when initializing
 nf_ct_expect_hash_rnd
Date: Wed, 05 Jan 2011 10:32:46 -0800 (PST)
Message-ID: <20110105.103246.193708786.davem@davemloft.net>
References: <1294237403-15616-1-git-send-email-xiaosuo@gmail.com>
	<1294250598.10633.77.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1294250598.10633.77.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 Jan 2011 19:03:18 +0100

> Le mercredi 05 janvier 2011 =E0 22:23 +0800, Changli Gao a =E9crit :
>> Since nf_ct_expect_dst_hash() may be called without nf_conntrack_loc=
k
>> locked, nf_ct_expect_hash_rnd should be initialized in the atomic wa=
y.
>>=20
>> In this patch, we use nf_conntrack_hash_rnd instead of
>> nf_ct_expect_hash_rnd.
>>=20
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Problem is Patrick seems not responsive these days ;)

As a result, I'll integrate this fix later today.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
