From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Wed, 28 Jun 2006 14:57:43 +1000
Message-ID: <20060628045743.GA5859@gondor.apana.org.au>
References: <1151464007.5124.13.camel@rh4> <20060628031052.GA4570@gondor.apana.org.au> <1151466034.5124.18.camel@rh4> <20060628034823.GA5125@gondor.apana.org.au> <1151469421.3502.3.camel@rh4> <20060628044209.GA5673@gondor.apana.org.au> <1151470479.3502.10.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:17931 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1423068AbWF1E5y
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 00:57:54 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1151470479.3502.10.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 27, 2006 at 09:54:39PM -0700, Michael Chan wrote:
>
> Assuming that we'll later have GSO_TCPV6, isn't it better to check for
> TCPV4 explicitly now?  Or just change it later when necessary.

Good point, I suppose you never know whether a V6 TSO-capable card is going
to handle ECN correctly in both cases.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
