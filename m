From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [1/5] [NET]: Merge TSO/UFO fields in sk_buff
Date: Thu, 22 Jun 2006 11:09:25 +1000
Message-ID: <20060622010925.GA22448@gondor.apana.org.au>
References: <20060620090919.GA31613@gondor.apana.org.au> <20060620091050.GA31854@gondor.apana.org.au> <1150926495.3475.5.camel@rh4> <20060621232741.GA21559@gondor.apana.org.au> <1150937184.4069.4.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56076 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030478AbWFVBJg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 21:09:36 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1150937184.4069.4.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 21, 2006 at 05:46:24PM -0700, Michael Chan wrote:
>
> OK, if time permits, I'll cook up some patches to support generic TSO
> ECN with or without hardware support.  Without hardware ECN, it will use
> GSO to split up the packet with CWR.  Can we assume that all hardware
> will handle ECE properly?

ECE just needs to be replicated so it would seem to be a safe bet unless
Dave knows some really broken hardware out there? If not I'd say that
we should just assume that it works and add a new bit it if said broken
stuff does turn up.

Thanks a lot for looking into this!

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
