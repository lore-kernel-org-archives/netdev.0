From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [15/*] [INET] Fix IPsec calculation in ip_append_data/ip6_append_data
Date: Tue, 22 Mar 2005 07:28:04 +1100
Message-ID: <20050321202804.GA3106@gondor.apana.org.au>
References: <20050214221607.GC18465@gondor.apana.org.au> <20050306213214.7d8a143d.davem@davemloft.net> <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050316113149.GA10960@gondor.apana.org.au> <423EF2CF.7020403@kolumbus.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: Mika Penttil? <mika.penttila@kolumbus.fi>
Content-Disposition: inline
In-Reply-To: <423EF2CF.7020403@kolumbus.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 21, 2005 at 06:14:07PM +0200, Mika Penttil? wrote:
>
> Shouldn't ip_output also use the path variant, dst_mtu(skb->dst->path), 
> it's surely after ipsec- processing?

That's the reason why it shouldn't use dst->path.  The only time you
should use dst_mtu(dst->path) is when dst may contain IPsec AND you
need the MTU outside IPsec.

In this case dst cannot contain IPsec so dst_mtu(dst) is correct.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
