From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: hardware time stamping with optional structs in data area
Date: Wed, 28 Jan 2009 20:08:21 +1100
Message-ID: <20090128090821.GA15770@gondor.apana.org.au>
References: <1233069837.24438.54.camel@pohly-MOBL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-api@vger.kernel.org
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53020 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751217AbZA1JI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 04:08:28 -0500
Content-Disposition: inline
In-Reply-To: <1233069837.24438.54.camel@pohly-MOBL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Ohly <patrick.ohly@intel.com> wrote:
>
> True - at this time. But what if this extension mechanism turns out to
> be useful and we end up with more optional structures? I was hoping that
> this might be the case and thus tried to make it easy to add more
> structures.

You're putting the extension in the skb->end area, right?

How big are the time stamps? If they're not that big, why don't
we put it into the shinfo structure itself? For the common case,
we have plenty of space due to kmalloc padding anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
