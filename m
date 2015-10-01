From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [regression] 6ae459bd skbuff: Fix skb checksum flag on skb pull
Date: Thu, 1 Oct 2015 19:21:34 +0800
Message-ID: <20151001112134.GA26657@gondor.apana.org.au>
References: <20151001084222.GA25104@gondor.apana.org.au>
 <1443698177.3401.1.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443698177.3401.1.camel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 01, 2015 at 01:16:17PM +0200, Mike Galbraith wrote:
> 
> > If this patch is indeed causing the regression you should be able
> > to spot some differences in the tcpdump.  Can you confirm this?
> 
> Will this work instead?

Thanks! Looks like the patch wasn't thought through.  It's testing
the offset after the pull but treating it as the offset before the
pull.

I'll send you a patch in a couple of minutes.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
