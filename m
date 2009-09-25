From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Why is LRO off by default on ixgbe?
Date: Fri, 25 Sep 2009 14:43:03 -0700
Message-ID: <20090925214303.GA3399@gondor.apana.org.au>
References: <4ABA57D1.5000905@candelatech.com> <20090925213727.GA3291@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54585 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752257AbZIYVnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 17:43:04 -0400
Content-Disposition: inline
In-Reply-To: <20090925213727.GA3291@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 25, 2009 at 02:37:27PM -0700, Herbert Xu wrote:
>
> > Ok.  It seems GRO was enabled the whole time, but LRO is what gave me the
> > extra performance boost.
> > 
> > In this particular case, I'm not actually routing, though I do have ip-forward
> > enabled, so I guess LRO will be OK as long as I'm careful...
> 
> What? A driver is either GRO or LRO, it can't be both.  What
> kernel version was this?

Oh perhaps you mean LRO performed by hardware? That would make
sense indeed.  It's also one of the reasons why we hope the hardware
folks would switch over to GRO so we can enable it for everyone :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
