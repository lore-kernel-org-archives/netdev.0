From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 01:36:47 +0200
Message-ID: <428A800F.6040809@trash.net>
References: <E1DYAHF-0006qW-00@gondolin.me.apana.org.au> <20050517.151352.41634495.davem@davemloft.net> <20050517230833.GA26604@gondor.apana.org.au> <20050517.161641.74747565.davem@davemloft.net> <20050517232828.GA26894@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, akepner@sgi.com,
        netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050517232828.GA26894@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Tue, May 17, 2005 at 04:16:41PM -0700, David S. Miller wrote:
> 
>>Good point, in both cases what ends up happening is that
>>the queue is invalidated.  In the existing case it's usually
>>because the final UDP or whatever checksum doesn't pass.
>>With your idea it'd be due to the artificially deflated timeout.
> 
> 
> It just occured to me that the optimisation in IPv4/IPv6 that performs
> fragmentation after tunnel-mode IPsec is fundamentally broken.  It
> makes IPsec vulnerable to fragmentation attacks.

You mean vulnerable at reassembly time? Isn't that something reassembly
and policy checks should take care of?

Regards
Patrick
