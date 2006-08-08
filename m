From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/2] [IPV4]: Use network-order dport for all visible inet_lookup_*
Date: Tue, 08 Aug 2006 23:40:40 +1000
Message-ID: <E1GARp2-0004F8-00@gondolin.me.apana.org.au>
References: <20060808132914.GA14433@infradead.org>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:20742 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964829AbWHHNlM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 09:41:12 -0400
To: hch@infradead.org (Christoph Hellwig)
In-Reply-To: <20060808132914.GA14433@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig <hch@infradead.org> wrote:
>
>> [IPV4]: Use network-order dport for all visible inet_lookup_*
> 
> Shouldn't it use __be16 types then?

Yes it should.

However, we can't easily annotate the stack piecemeal.  So this should
be annotated along with the rest of the stack (e.g., tcphdr, etc.).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
