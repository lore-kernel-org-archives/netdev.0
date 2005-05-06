From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: resend patch:  xfrm policybyid
Date: Fri, 6 May 2005 11:31:25 +1000
Message-ID: <20050506013125.GA31780@gondor.apana.org.au>
References: <1115298877.7680.75.camel@localhost.localdomain> <20050505213239.GA29526@gondor.apana.org.au> <1115331436.8006.112.camel@localhost.localdomain> <20050505231210.GA30574@gondor.apana.org.au> <1115342122.7660.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115342122.7660.25.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 05, 2005 at 09:15:22PM -0400, jamal wrote:
> 
> Thats a moot point really Herbert. I can think of a few apps that can
> use this, but it shouldnt matter: The main point is correctness.

Ah, that's why we're talking past each other :) You're looking at
it as a bug where we aren't setting the index when it is provided
by the user.

The way I'm seeing it is that the index is simply a read-only value
that's only provided by the kernel to the user as an aid in locating
policies.

In this respect it's just like xfrm_policy->curlft, it can be read
by the user by it's only ever written by the kernel.  So whatever
value the user provides us when adding/updating a policy is simply
ignored.

Another way to look at it is that it's a handle that we're returning
to the user so that they can talk about policies in an unambiguous way.

Does this make sense?

> You know what else you can do is get rid of the index totaly - that
> would be fine with me. What do you say to that?

That would break user API/ABI so no :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
