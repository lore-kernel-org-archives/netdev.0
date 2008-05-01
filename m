From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 1 May 2008 19:37:16 +0800
Message-ID: <20080501113716.GA7955@gondor.apana.org.au>
References: <20080430214845.GC14219@solarflare.com> <E1JrWFU-0001ue-00@gondolin.me.apana.org.au> <20080501110225.GG14219@solarflare.com> <1209640128.4191.30.camel@moonstone.uk.level5networks.com> <20080501111247.GA7756@gondor.apana.org.au> <1209640688.4191.35.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47245 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752149AbYEALhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 07:37:22 -0400
Content-Disposition: inline
In-Reply-To: <1209640688.4191.35.camel@moonstone.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 01, 2008 at 12:18:08PM +0100, Kieran Mansley wrote:
>
> If I remember rightly it also gets upset when it comes to split the
> packet because the frag_list is already in use; it expects this not to
> be the case for GSO but it's valid for an LRO packet to do this I think.
> I don't think there's anything fundamentally difficult here, it's just
> that the code has never been written to cope.

Oh so LRO packets still preserve the original packet boundaries?
That's even easier.  We could just make the GSO output code detect
the presence of frag_list and fragment based on that.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
