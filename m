From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Call dst_check() with appropriate cookie
Date: Tue, 24 May 2005 18:11:54 +1000
Message-ID: <20050524081154.GA31352@gondor.apana.org.au>
References: <20050524.124919.00464304.yoshfuji@linux-ipv6.org> <E1DaTeW-00085B-00@gondolin.me.apana.org.au> <20050524.163018.29919354.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, kazunori@miyazawa.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050524.163018.29919354.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 24, 2005 at 04:30:18PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> Honestly speaking, we haven't tracked down deeply where it is,
> but that patch is logically reauired and it definetely solves grave
> "freeze" issue with ipv6 tunnel mode xfrm.

I'm happy with your patch as it is.  However, I'd like us to track
this freeze down first because if it is caused by another bug then
this patch may make it harder to find it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
