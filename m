From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] rhashtable: remove insecure_max_entries param
Date: Tue, 25 Apr 2017 19:04:15 +0800
Message-ID: <20170425110415.GA25167@gondor.apana.org.au>
References: <20170425094134.21885-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fw@strlen.de
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.176.57.175] ([198.176.57.175]:47462 "EHLO
        deadmen.hmeau.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1031153AbdDYLFH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 07:05:07 -0400
Content-Disposition: inline
In-Reply-To: <20170425094134.21885-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal <fw@strlen.de> wrote:
> no users in the tree, insecure_max_entries is always set to
> ht->p.max_size * 2 in rhtashtable_init().
> 
> Replace only spot that uses it with a ht->p.max_size check.

I'd suggest that as this needs to be computed every time we insert
an element that you keep the value in struct rhashtable, but as an
internal value as opposed to a paramter that is set by the user.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
