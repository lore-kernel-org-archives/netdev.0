From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: xfrm_user: use BUG_ON instead of if condition
 followed by BUG
Date: Tue, 24 Oct 2017 12:30:51 +0800
Message-ID: <20171024043051.GA29883@gondor.apana.org.au>
References: <20171023181857.GA25379@embeddedor.com>
 <20171024032508.GC28462@gondor.apana.org.au>
 <20171023225043.Horde.R0FvJkHEmPPjnRNzKMOrPb3@gator4166.hostgator.com>
 <20171024035320.GA29795@gondor.apana.org.au>
 <20171024040144.bf2cvq7p6zwg2e5k@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:34860 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdJXEb1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 00:31:27 -0400
Content-Disposition: inline
In-Reply-To: <20171024040144.bf2cvq7p6zwg2e5k@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 23, 2017 at 09:01:46PM -0700, Alexei Starovoitov wrote:
>
> fwiw I had the same argument earlier:
> https://lkml.org/lkml/2017/10/9/1139

Fair point on eliminating a branch.  But I'd prefer something like

	bool cond;

	cond = code_that_does_something();
	BUG_ON(cond);

rather than just

	BUG_ON(code_that_does_something());

But maybe it's just me.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
