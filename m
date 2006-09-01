From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][IPSEC]: tunnel mode processing
Date: Fri, 1 Sep 2006 22:22:55 +1000
Message-ID: <20060901122255.GA18143@gondor.apana.org.au>
References: <1157072127.5057.39.camel@jzny2> <20060901040713.GA9840@gondor.apana.org.au> <1157113034.5057.62.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:16401 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751145AbWIAMW7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 08:22:59 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1157113034.5057.62.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 01, 2006 at 08:17:14AM -0400, jamal wrote:
> 
> In the case of traffic generation, if i could shave even more cycles the
> better since i want to generate high speed. In this case the cycles
> would be in creating a fake dst and attaching it some fake values.

Right, you're testing the receiver side.  In that case I suggest that
you replicate the IPsec transport mode logic in the generator.  Just
as pktgen doesn't use net/ipv4/udp.c to generate UDP traffic, it doesn't
really need to use xfrm4_output.c to generate IPsec traffic.

You can still call down to esp4.c through the type pointer of course.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
