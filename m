From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [AH6] Rearrange routing headers
Date: Sun, 25 Jul 2004 21:16:41 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040725111641.GA27265@gondor.apana.org.au>
References: <20040724083709.GA9416@gondor.apana.org.au> <200407250410.03741.kazunori@miyazawa.org> <20040725080347.GA20251@gondor.apana.org.au> <200407251532.13292.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori Miyazawa <kazunori@miyazawa.org>
Content-Disposition: inline
In-Reply-To: <200407251532.13292.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jul 25, 2004 at 03:32:13PM +0900, Kazunori Miyazawa wrote:
>
> routing is looked up with srcrt but xfrm is looked up with final
> destination, isn't it? we have the codes in our repository.

You're right.

I only skimmed through the code and took the presence of code that
dealt with the option/extension header as evidence that it did the
right thing :)

So both IPv4 and IPv6 are broken in this respect as they use the
first address rather than the final address for policy lookup.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
