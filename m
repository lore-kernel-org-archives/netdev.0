From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: patch: policy update by id
Date: Thu, 28 Apr 2005 12:22:16 +1000
Message-ID: <20050428022215.GA23517@gondor.apana.org.au>
References: <1114602874.7670.4.camel@localhost.localdomain> <1114604657.7670.22.camel@localhost.localdomain> <1114604826.7670.24.camel@localhost.localdomain> <20050427233924.GA22238@gondor.apana.org.au> <1114650816.7663.13.camel@localhost.localdomain> <20050428012135.GA22950@gondor.apana.org.au> <20050428013014.GA23043@gondor.apana.org.au> <1114653140.7663.36.camel@localhost.localdomain> <20050428020754.GA23326@gondor.apana.org.au> <1114654832.7663.56.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114654832.7663.56.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2005 at 10:20:32PM -0400, jamal wrote:
>
> > > 2) index really oughta be unique across the SPD.  
> > > Current behavior: I can add several new rules with the same index.
> > 
> > Not really.  The kernel ignores the index supplied when you're
> > adding them.
> 
> Whats the point of index then?

So that you can delete policies without specifying the whole selector.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
