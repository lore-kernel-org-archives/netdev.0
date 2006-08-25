From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 40/44] [XFRM] POLICY: sub policy support.
Date: Fri, 25 Aug 2006 11:45:41 +1000
Message-ID: <E1GGQlR-0007Fm-00@gondolin.me.apana.org.au>
References: <20060823.224800.124082063.davem@davemloft.net>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:11013 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1422818AbWHYBqR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 21:46:17 -0400
To: davem@davemloft.net (David Miller)
In-Reply-To: <20060823.224800.124082063.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> 
> Those socket policies are becomming more and more difficult to
> deal with.  I like them as a feature, but I wonder who uses
> them :-)  They do not live in the flow cache so they hurt
> performance until we find a way to place them there.  Perhaps
> we can extend the flow keying somehow to account for socket
> based policies in the flow cache.

The KM's use it to allow ISAKMP traffic to punch through IPsec.

That should definitely be the exception though.  Most apps should
have zero socket policies, especially since socket policies need
root privileges.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
