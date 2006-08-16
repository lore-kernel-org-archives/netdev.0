From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][IPSEC]: Aggregate make_jiffies
Date: Wed, 16 Aug 2006 23:24:34 +1000
Message-ID: <20060816132434.GA30646@gondor.apana.org.au>
References: <1155693500.5122.39.camel@jzny2> <20060816023349.GA24174@gondor.apana.org.au> <1155697186.5122.43.camel@jzny2> <1155733994.5122.140.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33550 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750777AbWHPNYv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 09:24:51 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1155733994.5122.140.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2006 at 09:13:14AM -0400, jamal wrote:
> 
> Herbert, I actually dont know the answer that is why i am punting it to
> you;-> I would just move the whole thing to linux/jiffies.h as is but
> you seem to suggest there may be other boundary checks. If yes, go at
> it ;->

I think it's just the boundary check.  If you rewrite the function in
the same fashion as msec_to_jiffies then it should be OK.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
