From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [x86_64, NET] smp_rmb() in dst_destroy() seems very expensive, ditto in kfree_skb()
Date: Fri, 05 May 2006 20:06:01 +1000
Message-ID: <E1FbxCD-0003rt-00@gondolin.me.apana.org.au>
References: <445B11A3.1020407@cosmosbay.com>
Cc: davem@davemloft.net, ak@suse.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57092 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030351AbWEEKGV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 06:06:21 -0400
To: dada1@cosmosbay.com (Eric Dumazet)
In-Reply-To: <445B11A3.1020407@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> wrote:
>
> I missed the corresponding wmb that should be done somewhere in the dst 
> code.

The wmb for dst's is in dst_release while skb's have an implicit barrier
through atomic_dec_and_test in kfree_skb.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
