From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Unnecessary check in __sk_stream_mem_reclaim?
Date: Wed, 12 Jul 2006 13:12:13 +1000
Message-ID: <E1G0V93-00037K-00@gondolin.me.apana.org.au>
References: <5640c7e00607111942jc0ef6cdyc0466dc0cfd5a00b@mail.gmail.com>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2565 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932360AbWGLDMX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 23:12:23 -0400
To: ian.mcdonald@jandi.co.nz (Ian McDonald)
In-Reply-To: <5640c7e00607111942jc0ef6cdyc0466dc0cfd5a00b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> 
> It looks to me like this check here in net/core/stream.c for
> __sk_stream_mem_reclaim:
>        if (sk->sk_forward_alloc >= SK_STREAM_MEM_QUANTUM) {
> 
> is unnecessary.

It's needed after skb's have been freed which can push sk_forward_alloc
above a quantum.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
