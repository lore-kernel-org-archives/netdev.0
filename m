From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: resend patch:  xfrm policybyid
Date: Sat, 7 May 2005 20:55:00 +1000
Message-ID: <20050507105500.GA20283@gondor.apana.org.au>
References: <1115298877.7680.75.camel@localhost.localdomain> <20050505213239.GA29526@gondor.apana.org.au> <1115331436.8006.112.camel@localhost.localdomain> <20050505231210.GA30574@gondor.apana.org.au> <1115342122.7660.25.camel@localhost.localdomain> <20050506013125.GA31780@gondor.apana.org.au> <1115345403.7660.49.camel@localhost.localdomain> <20050506085404.GA26719@gondor.apana.org.au> <1115380381.7660.123.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115380381.7660.123.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 06, 2005 at 07:53:00AM -0400, jamal wrote:
> 
> You are a reasonable man, so i am hoping you will end agreeing 
> or agreeing to disagree;->

If it weren't for the fact that the only way of achieving what you
want here is through ugly code then I wouldn't have any problems with
it at all.
 
> > There should only be one key that the
> > user gets to set when adding policies that is guaranteed to be unique.
> > As it is it's the selector.
> 
> Note: The index was already guaranteed to be unique even without my
> patch.

The difference is that the uniqueness is easy when we (the kernel) are
the only ones setting it.  Once you let the user choose the value for
index, that's where the horror starts.

> Just to make sure we are not speaking past each other:
> A key is a column in a table that can be uniquely used to identify said
> row. 

Yep.

> In this case actually the justification exists: The selector is needed
> for data/packet path lookup key. The index for manager side
> manageability. 

I have no argument with the existence of the index per se.  What I am
yet to be convinced of is the need for the user to set its value.
 
> > However, I must say that I still have absolutely no idea why anyone
> > would need to set the index to arbitrary values.
> 
> But you do know why someone would want to search or delete by it,
> right?;->

What difference does it make if you can set the value of index? What
things can't I do if I have to use the index value given by the kernel?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
