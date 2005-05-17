From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 09:28:28 +1000
Message-ID: <20050517232828.GA26894@gondor.apana.org.au>
References: <E1DYAHF-0006qW-00@gondolin.me.apana.org.au> <20050517.151352.41634495.davem@davemloft.net> <20050517230833.GA26604@gondor.apana.org.au> <20050517.161641.74747565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akepner@sgi.com, netdev@oss.sgi.com,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050517.161641.74747565.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2005 at 04:16:41PM -0700, David S. Miller wrote:
> 
> Good point, in both cases what ends up happening is that
> the queue is invalidated.  In the existing case it's usually
> because the final UDP or whatever checksum doesn't pass.
> With your idea it'd be due to the artificially deflated timeout.

It just occured to me that the optimisation in IPv4/IPv6 that performs
fragmentation after tunnel-mode IPsec is fundamentally broken.  It
makes IPsec vulnerable to fragmentation attacks.

We have to perform fragmentation before tunnel-mode IPsec.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
