From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: take 2-2  WAS(Re: PATCH: IPSEC xfrm events
Date: Tue, 5 Apr 2005 07:31:49 +1000
Message-ID: <20050404213149.GA15222@gondor.apana.org.au>
References: <1112406164.1088.54.camel@jzny.localdomain> <20050402014619.GB24861@gondor.apana.org.au> <1112469601.1088.173.camel@jzny.localdomain> <1112538718.1096.394.camel@jzny.localdomain> <20050404005805.GA16543@gondor.apana.org.au> <1112614706.1096.439.camel@jzny.localdomain> <20050404121641.GA12103@gondor.apana.org.au> <1112619096.1088.473.camel@jzny.localdomain> <20050404130224.GA12546@gondor.apana.org.au> <1112620614.1088.489.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112620614.1088.489.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Apr 04, 2005 at 09:16:55AM -0400, jamal wrote:
> 
> Ok, fair enough. It annoys me too when i review patches ;->
> So i will fix this before final.

Just one more thing, can you please remove the _bh's that you
added to the read_lock for xfrm_km_list? It turns out that they're
not necessary since the write_lock()'s are only held in process
context.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
