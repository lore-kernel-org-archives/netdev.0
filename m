From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: patch: policy update by id
Date: Thu, 28 Apr 2005 12:07:54 +1000
Message-ID: <20050428020754.GA23326@gondor.apana.org.au>
References: <1114602874.7670.4.camel@localhost.localdomain> <1114604657.7670.22.camel@localhost.localdomain> <1114604826.7670.24.camel@localhost.localdomain> <20050427233924.GA22238@gondor.apana.org.au> <1114650816.7663.13.camel@localhost.localdomain> <20050428012135.GA22950@gondor.apana.org.au> <20050428013014.GA23043@gondor.apana.org.au> <1114653140.7663.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114653140.7663.36.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2005 at 09:52:20PM -0400, jamal wrote:
>
> > 1) There is only one policy with a given selector.
> > 2) There is only one policy with a given index.
> 
> Well, while snooping i was bothered as well. I am not sure i agree with
> your #1 above ;->
> 
> 1) It would seem to me that the priority field is to be used 
> as a ambiguity resolver (thats what a gazillion other classification
> schemes do). 

You know what, I actually agree with you :) But you'll need to convince
Dave:

http://www.uwsg.iu.edu/hypermail/linux/net/0305.3/0018.html

However, this doesn't change the fact that you may need to delete
two policies.

> 2) index really oughta be unique across the SPD.  
> Current behavior: I can add several new rules with the same index.

Not really.  The kernel ignores the index supplied when you're
adding them.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
