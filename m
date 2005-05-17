From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 09:41:58 +1000
Message-ID: <20050517234158.GA27006@gondor.apana.org.au>
References: <E1DYAHF-0006qW-00@gondolin.me.apana.org.au> <20050517.151352.41634495.davem@davemloft.net> <20050517230833.GA26604@gondor.apana.org.au> <20050517.161641.74747565.davem@davemloft.net> <20050517232828.GA26894@gondor.apana.org.au> <428A800F.6040809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, akepner@sgi.com,
        netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <428A800F.6040809@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2005 at 01:36:47AM +0200, Patrick McHardy wrote:
> 
> You mean vulnerable at reassembly time? Isn't that something reassembly
> and policy checks should take care of?

I mean that it's vulnerable to the following simple DoS attack by
someone who doesn't otherwise have the capability to drop the
packets between the source and the target.

If the IPsec packets arrive as fragments, the attacker only needs
to guess the identity to cause the entire IPsec packet to be dropped.

If it was fragmented prior to IPsec it would not be vulnerable to
this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
