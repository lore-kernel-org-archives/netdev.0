From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Tue, 28 Sep 2004 07:36:07 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927213607.GD7243@gondor.apana.org.au>
References: <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net> <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net> <20040922045239.GA19573@gondor.apana.org.au> <1095854920.1047.64.camel@jzny.localdomain> <20040923120707.GB32624@gondor.apana.org.au> <1095995042.1044.34.camel@jzny.localdomain> <20040924032440.GB6384@gondor.apana.org.au> <1096289189.1075.37.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1096289189.1075.37.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 08:46:30AM -0400, jamal wrote:
> > 
> > 1) Request/response:
> > 
> > No overruns should occur.
> 
> Cant assume this. A request for an ACK is fine. A get is a different
> ball game.

What I meant is that this is a case where the maximum size of the reply
can be known at compile time.  So assuming that your socket receive size
is set correctly, it should never overflow.

> > 3) Async messages:
> > 
> > Overruns may occur if the arrival rate exceeds the application's
> > processing capacity or if the queue is too small for a burst.
> > 
> > Now we were discussing about how we can do congestion control for 3).
> > But to do that we need to know exactly what these messages are.  For
> > example if they're coming from an external source as is the case in
> > ip_queue then you can't congestion control it at all.

You still haven't told me what you're going to use 3) for yet...

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
