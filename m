From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] rhashtable: remove insecure_max_entries param
Date: Tue, 25 Apr 2017 21:28:37 +0800
Message-ID: <20170425132837.GA25657@gondor.apana.org.au>
References: <20170425094134.21885-1-fw@strlen.de>
 <20170425110415.GA25167@gondor.apana.org.au>
 <20170425112356.GB11322@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.176.57.175] ([198.176.57.175]:47514 "EHLO
        deadmen.hmeau.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1430559AbdDYN3D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 09:29:03 -0400
Content-Disposition: inline
In-Reply-To: <20170425112356.GB11322@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 01:23:56PM +0200, Florian Westphal wrote:
>
> What extra cost?
> 
> The only change is that ht->nelems has to be right-shifted by one,
> I don't think that warrants extra space in struct rhashtable, its
> already way too large (I think we can reduce its size further).

I see at least one hole on 64-bit which means that you can fit
it into struct rhashtable for free.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
