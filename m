From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [4/4] [IPSEC] Store MTU at each xfrm_dst
Date: Wed, 16 Feb 2005 07:31:12 +1100
Message-ID: <20050215203112.GA16313@gondor.apana.org.au>
References: <20050214221607.GC18465@gondor.apana.org.au> <Xine.LNX.4.44.0502151050080.29775-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0502151050080.29775-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Feb 15, 2005 at 10:53:11AM -0500, James Morris wrote:
> 
> The only thing I'd suggest is to consider renaming the new route element
> of xfrm_dst to xfrm_dst_route (or xd_route), to make it easier to navigate
> the code.  (But the other elements are not distinctive either so perhaps 
> some future cleanup could do it).

Thanks for your comment.

I would say that not only are the other elements of xfrm_dst missing
the prefixes, but the same thing applies to the rest of xfrm.h :)

So if we decide to go that way, then we should do it to the entire
xfrm subsystem.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
