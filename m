From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fwd: Re: Ethernet over GRE ?
Date: Wed, 4 Feb 2009 07:47:34 +1100
Message-ID: <20090203204734.GA13337@gondor.apana.org.au>
References: <20090203131512.GA4722@libertysurf.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Lefevre <david.lefevre7@libertysurf.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44130 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751891AbZBCUrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 15:47:41 -0500
Content-Disposition: inline
In-Reply-To: <20090203131512.GA4722@libertysurf.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 02:15:12PM +0100, David Lefevre wrote:
>
> > thanks for the new release of iproute2 (corresponding to 2.6.28).
> > I'm still confused : I can create a "gretap" interface and add it to a bridge (with brtcl addif) but, in that case, I don't know how to use this interface as a tunnel (GRE). And if I set up a tunnel, I cannot add it as an interface in the bridge.

Using gretap is the correct way to go.  What do you mean that
you don't know how to use it as a tunnel?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
