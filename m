From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: v6-in-v4 IPsec and NAT traversal
Date: Mon, 15 Mar 2004 22:36:43 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1B2qOh-0005S9-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.44.0403131452280.25018-100000@netcore.fi>
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi (Pekka Savola), netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.44.0403131452280.25018-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pekka Savola <pekkas@netcore.fi> wrote:
> 
> Is this planned?  Are there issues with "native" support why it would 
> not be feasible?

http://www.spinics.net/lists/linux-net/msg08197.html

> Avoiding double encapsulation would be IMHO really useful, and several 
> other implementations are already reported to allow this.

There is no double encapsulation.  Using an SIT tunnel inside a
transport v4 SA is equivalent to a v6/v4 SA in terms of overhead.

However, you do lose the ability to negotiate the selector but
you can always use netfilter to fix it up.
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
