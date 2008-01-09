From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [SOCK]: Adds a rcu_dereference() in sk_filter
Date: Wed, 09 Jan 2008 17:17:06 +1100
Message-ID: <E1JCUFO-00079j-00@gondolin.me.apana.org.au>
References: <4783DDBF.2040303@cosmosbay.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, dim@openvz.org,
	kuznet@ms2.inr.ac.ru
To: dada1@cosmosbay.com (Eric Dumazet)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2644 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750925AbYAIGRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 01:17:15 -0500
In-Reply-To: <4783DDBF.2040303@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
> It seems commit fda9ef5d679b07c9d9097aaf6ef7f069d794a8f9 introduced a RCU 
> protection for sk_filter(), without a rcu_dereference()
> 
> Either we need a rcu_dereference(), either a comment should explain why we 
> dont need it. I vote for the former.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
