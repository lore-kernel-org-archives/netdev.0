From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Wed, 28 Jun 2006 13:48:23 +1000
Message-ID: <20060628034823.GA5125@gondor.apana.org.au>
References: <1151464007.5124.13.camel@rh4> <20060628031052.GA4570@gondor.apana.org.au> <1151466034.5124.18.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35850 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932084AbWF1Dse
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 23:48:34 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1151466034.5124.18.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 27, 2006 at 08:40:34PM -0700, Michael Chan wrote:
>
> We need to turn off NETIF_F_TSO for a connection that has negotiated to
> turn on ECN if the output device cannot handle TSO and ECN.  In other
> words, if the output device does not have either GSO or TSO_ECN feature
> set.

I think you're mixing up GSO the mechanism with GSO the flag.  The GSO
flag simply tells the TCP stack whether TSO should be used or not, even
if the hardware does not support TSO at all.  The GSO mechanism on the
other hand is ALWAYS present.  So regardless of the presence of the GSO
flag, you can always rely on the GSO mechanism to pick up the pieces (or
rather generate the pieces as the case may be :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
