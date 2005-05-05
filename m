From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: resend patch:  xfrm policybyid
Date: Fri, 6 May 2005 09:12:10 +1000
Message-ID: <20050505231210.GA30574@gondor.apana.org.au>
References: <1115298877.7680.75.camel@localhost.localdomain> <20050505213239.GA29526@gondor.apana.org.au> <1115331436.8006.112.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115331436.8006.112.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 05, 2005 at 06:17:15PM -0400, jamal wrote:
>
> > This is still racy since delp can be killed by timers before you get
> > the lock.
> 
> Ok, Herbert - this is fixable: I take it moving the lock one up is
> sufficient; i dont mind if you fix it and add it to your list.

I know it's fixable, but the problem is that the fix is likely to
make this function even uglier :)

What I still don't get is who would be using this feature.  No I
don't mean an example of how the ip command can do this :) I mean
a real-world scenario why someone or some KM would want do this and
why it can't be done easily with what we've already got.

BTW I very much like part where you added the dir to the policy
structure.  So if that can be split off I'd have no objections
in seeing it included.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
