From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC]: searching  SAD without assumming L3 details
Date: Wed, 6 Sep 2006 21:26:44 +1000
Message-ID: <20060906112644.GA22930@gondor.apana.org.au>
References: <1157204582.5197.4.camel@jzny2> <20060905233823.GA9217@gondor.apana.org.au> <1157541639.5039.28.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:13837 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750808AbWIFL0x
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 07:26:53 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1157541639.5039.28.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 06, 2006 at 07:20:39AM -0400, jamal wrote:
>
> > Any reason why xfrm_state_find can't be used? 
> 
> xfrm_state_find is overkill (if you compare the two functionalities). 

Could you show me how you plan to use this in pktgen? Perhaps we can
move it to the slow path where it wouldn't matter whether it's an
overkill or not.  There should be no reason to be looking up an SA
in the pktgen fast path.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
