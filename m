From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][IPSEC]: tunnel mode processing
Date: Fri, 1 Sep 2006 14:07:13 +1000
Message-ID: <20060901040713.GA9840@gondor.apana.org.au>
References: <1157072127.5057.39.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:61190 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750907AbWIAEHW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 00:07:22 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1157072127.5057.39.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2006 at 08:55:27PM -0400, jamal wrote:
> 
> Would it be reasonable to do a check so that incase a skb->dst doesnt
> exist, the inner headers values can be used i.e something along 
> xfrm4_tunnel_output()::

If you didn't care what values they were, couldn't you just stuff some
bogus dst into the skb? If this packet is going somewhere you're going
to have a dst one way or another :)

Also, the IPID is only generated if DF is not set on the packet.
Otherwise this path is already as fast as it can be.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
