From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 'default' vs. 'all'
Date: Sat, 8 Dec 2007 19:21:57 +0800
Message-ID: <20071208112157.GB19431@gondor.apana.org.au>
References: <20071208.000429.66028544.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yoshifuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2040 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751427AbXLHLWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 06:22:01 -0500
Content-Disposition: inline
In-Reply-To: <20071208.000429.66028544.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 08, 2007 at 12:04:29AM -0800, David Miller wrote:
> 
> Herbert, Yoshifuji and I were just discussing the
> sysfs device attribute issue.
> 
> It's seems sane to me that if we had some kind of
> 'dirty' bit per attribute we could propagate default
> settings everywhere except where the dirty bit had
> been set.

Yep.

> The question is how to implement this nicely.
> 
> What do you think?

Well this is how it works on IPv4 already :)

The only thing is that we forcibly set the dirty bit on everything
when an address is added for backwards compatibility.

If you delete that call then it's as you described.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
