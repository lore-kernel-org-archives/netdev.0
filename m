From: jamal <hadi@cyberus.ca>
Subject: Re: patch: policy update by id
Date: Wed, 27 Apr 2005 22:29:59 -0400
Message-ID: <1114655399.7663.67.camel@localhost.localdomain>
References: <1114602874.7670.4.camel@localhost.localdomain>
	 <1114604657.7670.22.camel@localhost.localdomain>
	 <1114604826.7670.24.camel@localhost.localdomain>
	 <20050427233924.GA22238@gondor.apana.org.au>
	 <1114650816.7663.13.camel@localhost.localdomain>
	 <20050428012135.GA22950@gondor.apana.org.au>
	 <20050428013014.GA23043@gondor.apana.org.au>
	 <1114653140.7663.36.camel@localhost.localdomain>
	 <20050428020754.GA23326@gondor.apana.org.au>
	 <1114654832.7663.56.camel@localhost.localdomain>
	 <20050428022215.GA23517@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050428022215.GA23517@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-28-04 at 12:22 +1000, Herbert Xu wrote:
> On Wed, Apr 27, 2005 at 10:20:32PM -0400, jamal wrote:

> > Whats the point of index then?
> 
> So that you can delete policies without specifying the whole selector.
> 

Thats fine - same with get by index.
But if i am managing the policies I should be able to specify the
indices of choice. The kernel should assign me one when i dont define an
index. It should also reject what i pass if it the index is already in
use.  This is a very standard scheme for managing tables.

cheers,
jamal
