From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [3/4] [IPSEC] Add route element to xfrm_dst
Date: Mon, 7 Mar 2005 21:02:09 +1100
Message-ID: <20050307100209.GA7137@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050306212800.43d3d42e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050306212800.43d3d42e.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Mar 06, 2005 at 09:28:00PM -0800, David S. Miller wrote:
> 
> I guess this back traversal list makes it impossible for us
> to share xfrm_dst's for multiple unique flows even if that
> could be possible, right?

I used the back traversal only because it was convenient.  There is
nothing fundamental about it.

So if we ever implemented xdst sharing, we could easily modify
the couple of functions involved to walk the bundle forward and
then in reverse.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
