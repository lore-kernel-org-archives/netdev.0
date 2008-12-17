From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 21:31:29 +1100
Message-ID: <20081217103129.GA17248@gondor.apana.org.au>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi> <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ptesarik@suse.cz
To: Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52612 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752805AbYLQKbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 05:31:36 -0500
Content-Disposition: inline
In-Reply-To: <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 09:13:22PM +1100, Herbert Xu wrote:
> Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > 
> > This is certainly nice and possible but as mention earlier, the harder 
> > problem is that the urg_ptr is only 16-bits so there will be still be 
> > problem if the urgent seq-64k mark is within a super-skb as tail segments 
> > need urg while the head ones won't. I think we would need out-of-band 
> > means to communicate the extra bit (17th) from tcp if we want to solve 
> > that one. It would be rather easy to change TCP to only do splitting for 
> > that particular skb though and keep everything else intact.
> 
> I think you've got it the wrong way around.  The test for setting
> urg_ptr is:

Oh I see what you mean now.  Yes this isn't as easy as it appears.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
