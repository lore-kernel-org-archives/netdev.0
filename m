From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netdev: Netfilters on outgoing interfamily ipsec
Date: Fri, 19 Oct 2007 20:55:55 +0800
Message-ID: <20071019125555.GA13955@gondor.apana.org.au>
References: <200710191437.39449.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3272 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757341AbXJSM4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 08:56:03 -0400
Content-Disposition: inline
In-Reply-To: <200710191437.39449.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2007 at 02:37:38PM +0300, Joakim Koskela wrote:
> Hi,
> 
> I understand that Herbert is in midst of cleaning up the output of
> interfamily transformations, but I thought I'd post a couple of
> patches related to that anyway, sort of to show what we've needed to
> fix to get our systems working.
> 
> This one changes how the netfilters are applied during output to be
> based on the current address family of the packet instead of what it
> will be transformed to.

While I agree that this is definitely a problem, I've already
got a solution for it which we happen to need for async crypto
anyway.

Basically xfrm_output will invoke a continuation function based
on the external mode/family which will then call the right hooks.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
