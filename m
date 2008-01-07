From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [IPV4] ROUTE: Avoid sparse warnings
Date: Mon, 07 Jan 2008 21:46:45 +0100
Message-ID: <47828FB5.1030303@cosmosbay.com>
References: <20080107120117.aeebd0c8.dada1@cosmosbay.com> <E1JBqpd-0006vB-00@gondolin.me.apana.org.au> <20080107145624.05918cea.dada1@cosmosbay.com> <20080107203845.GA29803@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	viro@ZenIV.linux.org.uk
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:46504 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754325AbYAGUq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 15:46:59 -0500
In-Reply-To: <20080107203845.GA29803@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu a =E9crit :
> On Mon, Jan 07, 2008 at 02:56:24PM +0100, Eric Dumazet wrote:
>> AFAIK, this patch reduces complexity and text size.
>=20
> But if we had loads of empty hash buckets couldn't this potentially
> increase latency by disabling BH longer than before?

Well, we call rcu_read_unlock_bh()/rcu_read_lock_bh() for each bucket, =
empty=20
or not, before and after patch, so we dont change latency.



