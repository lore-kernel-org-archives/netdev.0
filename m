From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 2/7] rhashtable: Allow hash/comparison functions to be
 inlined
Date: Fri, 20 Mar 2015 23:02:28 +1100
Message-ID: <20150320120228.GA18736@gondor.apana.org.au>
References: <20150320105421.GA18148@gondor.apana.org.au>
 <E1YYubs-0004l5-Dt@gondolin.me.apana.org.au>
 <20150320112041.GF28736@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:59376 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbbCTMCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 08:02:37 -0400
Content-Disposition: inline
In-Reply-To: <20150320112041.GF28736@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 11:20:42AM +0000, Patrick McHardy wrote:
>
> I haven't checked in detail yet whether this still satisfies what
> we need in nftables, just a minor comment below:

AFAIK I have done nothing to break multiple keys as yet and
the comparison function is still there, just embedded into the
params structure.

> > +struct rhashtable_compare_arg {
> > +	struct rhashtable *ht;
> > +	const void *key;
> > +};
> 
> I found it a bit odd in the old interface that elementary data
> such as the key for comparision is encapsulated into a structure
> instead of passed as a function argument. Is there a reason
> for not passing both as arguments so we can at least avoid the
> encapsulation for the common case?

I don't have any objections against changing it but it could
be done outside of this particular patch-set.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
