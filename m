From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sendmsg ignoring bind?
Date: Fri, 20 May 2005 23:24:29 +1000
Message-ID: <20050520132429.GA32695@gondor.apana.org.au>
References: <20050520081805.GR25658@wiggy.net> <20050520101749.GA8661@gondor.apana.org.au> <20050520132009.GD4151@wiggy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>
Content-Disposition: inline
In-Reply-To: <20050520132009.GD4151@wiggy.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 20, 2005 at 03:20:09PM +0200, Wichert Akkerman wrote:
> 
> I had to hack strace a bit to decode that. The cmsg option turns out
> to be somewhat useless:

I suppose we can expect to have this in a future release of strace :)

> cmsg_type=IP_PKTINFO, {ifindex=0,ipi_spec_dst=inet_addr("0.0.0.0"),ipi_addr=("0.0.0.0")}}, msg_flags=0},

This is far from useless.  This will set the source address back to zero
which essentially means that the bound address is ignored.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
