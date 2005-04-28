From: jamal <hadi@cyberus.ca>
Subject: Re: patch: policy update by id
Date: Wed, 27 Apr 2005 22:20:32 -0400
Message-ID: <1114654832.7663.56.camel@localhost.localdomain>
References: <1114602874.7670.4.camel@localhost.localdomain>
	 <1114604657.7670.22.camel@localhost.localdomain>
	 <1114604826.7670.24.camel@localhost.localdomain>
	 <20050427233924.GA22238@gondor.apana.org.au>
	 <1114650816.7663.13.camel@localhost.localdomain>
	 <20050428012135.GA22950@gondor.apana.org.au>
	 <20050428013014.GA23043@gondor.apana.org.au>
	 <1114653140.7663.36.camel@localhost.localdomain>
	 <20050428020754.GA23326@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050428020754.GA23326@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-28-04 at 12:07 +1000, Herbert Xu wrote:

> You know what, I actually agree with you :) But you'll need to convince
> Dave:
> 
> http://www.uwsg.iu.edu/hypermail/linux/net/0305.3/0018.html
> 
> However, this doesn't change the fact that you may need to delete
> two policies.
> 

It certainly may be simpler to just allow no more than selector.
It reduces the value of priorities to be resolving ambiguities between
matches perhaps with overlapping areas by prefix lengths.

> > 2) index really oughta be unique across the SPD.  
> > Current behavior: I can add several new rules with the same index.
> 
> Not really.  The kernel ignores the index supplied when you're
> adding them.
> 

Whats the point of index then?

cheers,
jamal
