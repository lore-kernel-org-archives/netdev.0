From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [XFRM]: xfrm_algo_clone() allocates too much memory
Date: Wed, 09 Jan 2008 08:51:39 +0100
Message-ID: <47847D0B.3050003@cosmosbay.com>
References: <E1JCUDY-000791-00@gondolin.me.apana.org.au>	<478477C7.9030004@cosmosbay.com> <20080108.234012.181072357.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:42441 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbYAIHvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 02:51:53 -0500
In-Reply-To: <20080108.234012.181072357.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 09 Jan 2008 08:29:11 +0100
>=20
> Thanks for catching this.
>=20
> Applied to net-2.6
>=20
>> +static inline int xfrm_alg_len(struct xfrm_algo *alg)
>> +{
>> +	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
>> +}
>=20
> That gets emitted as a divide doesn't it :-))))
>=20
>=20
Yes I have a patch for these divides, but will apply on 2.6.25 once thi=
s one=20
hits it.  (this saves 192 bytes of kernel text BTW)

