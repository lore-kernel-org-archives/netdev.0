From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: patch2: del/get byid
Date: Thu, 28 Apr 2005 13:03:25 +1000
Message-ID: <20050428030325.GB23823@gondor.apana.org.au>
References: <1114654284.7663.50.camel@localhost.localdomain> <20050428021426.GA23415@gondor.apana.org.au> <1114655014.7663.61.camel@localhost.localdomain> <20050428022549.GA23556@gondor.apana.org.au> <1114655980.7663.76.camel@localhost.localdomain> <20050428024253.GA23695@gondor.apana.org.au> <1114656932.7663.88.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114656932.7663.88.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2005 at 10:55:32PM -0400, jamal wrote:
> 
> Dang ;-> Thats some abuse ;->

Indeed, looks like it was my code too :)

> It would probably be easy to steal 2 bits off the flags instead, no?

Or we can simply put it in a field called dir and start using it
instead of passing it around :)

With respect to the user specifying the index when adding policies,
I think we should check with Alexey.  He added the original code to
do this so maybe there was a problem with KAME that makes this
necessary.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
