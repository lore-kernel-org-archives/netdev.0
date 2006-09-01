From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][IPSEC]: tunnel mode processing
Date: Fri, 1 Sep 2006 23:04:38 +1000
Message-ID: <20060901130438.GA18536@gondor.apana.org.au>
References: <1157072127.5057.39.camel@jzny2> <20060901040713.GA9840@gondor.apana.org.au> <1157113034.5057.62.camel@jzny2> <20060901122255.GA18143@gondor.apana.org.au> <1157115379.5057.84.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:18194 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750924AbWIANEj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 09:04:39 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1157115379.5057.84.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 01, 2006 at 08:56:18AM -0400, jamal wrote:
> 
> Thats one idea i havent thought of. 
> 
> i.e the code would look like:
> -----
>         if (mode == tunnel) 
> 		err = mytunneloutput (x, skb);
> 	else 
>         	err = x->mode->output(x, skb);
>         if (err)
>                 goto error;
>         err = x->type->output(x, skb);
> --
> 
> This is what you are suggesting?

Yes, I suppose you could even replace x->mode directly.

> I am probably better off going back to creating a dummy dst with just
> those two fields when in  tunnel mode;->

Probably.  Although if you write your own output function you could
make it go faster by adapting it to the specifics of pktgen.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
