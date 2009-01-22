From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Thu, 22 Jan 2009 17:32:06 +1100
Message-ID: <20090122063206.GA11818@gondor.apana.org.au>
References: <49780AA9.9050508@iki.fi> <20090121.220304.211246256.davem@davemloft.net> <49780EB5.60300@iki.fi> <20090121.222112.245293949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35070 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753929AbZAVGcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 01:32:14 -0500
Content-Disposition: inline
In-Reply-To: <20090121.222112.245293949.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2009 at 10:21:12PM -0800, David Miller wrote:
>
> > I would not consider this a new feature. It just makes pfkey
> > act consistently. If you don't want it supported, it'd make
> > more sense to not #define SADB_X_EXT_NAT_T_OA and drop all of
> > the verification code already present than to silently
> > ignore it. Make kernel return an error if some tried using it.
> 
> Fair enough, sounds like a reasonable argument.
> 
> Herbert what do you think?  The proposal is that we just reflect the
> value we get, rather than acting upon it.

The only references to SADB_X_EXT_NAT_T_OA in our kernel currently
are for the user => kernel direction.  This patch does kernel =>
user so I don't see a connection.

In any case I just grabbed the latest ipsec-tools source and it
doesn't use this stuff at all so IMO this is a new feature.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
