From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: patch: policy update by id
Date: Thu, 28 Apr 2005 11:48:18 +1000
Message-ID: <20050428014818.GA23148@gondor.apana.org.au>
References: <1114602874.7670.4.camel@localhost.localdomain> <1114604657.7670.22.camel@localhost.localdomain> <1114604826.7670.24.camel@localhost.localdomain> <20050427233924.GA22238@gondor.apana.org.au> <1114650816.7663.13.camel@localhost.localdomain> <20050428012135.GA22950@gondor.apana.org.au> <1114652680.7663.31.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114652680.7663.31.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2005 at 09:44:40PM -0400, jamal wrote:
> 
> > I see.  In that case you want to change your expression above
> > so that the memcmp is never done if excl is off and the index
> > is non-zero.
> 
> Hrm. Thinking... So you want to exclude the selector check if someone
> updating ever specified the index? That may change things a little, no?
> Give me a clever expression.

Please see my last email.  To do index updates correctly we'll need
to modify the current code so that it is able to delete two existing
policies.  We may have two existing policies if one matches the index
while the other matches the selector.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
