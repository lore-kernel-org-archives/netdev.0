From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Tue, 2 Dec 2003 09:05:09 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031201220509.GA20827@gondor.apana.org.au>
References: <20031201201651.GA20194@gondor.apana.org.au> <20031201204700.GA20349@gondor.apana.org.au> <20031201135154.6906454c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031201135154.6906454c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Dec 01, 2003 at 01:51:54PM -0800, David S. Miller wrote:
> 
> Herbert, do you see how the outer loop and the skey[] thing works in
> this PMTU handling code?  This takes care of comparing both iph->saddr
> and '0' against rt->rt_src.

It only takes care of fl4_src, not rt_src.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
