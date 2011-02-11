From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: GRO/GSO hiding PMTU?
Date: Fri, 11 Feb 2011 11:07:21 +1100
Message-ID: <20110211000721.GA25457@gondor.apana.org.au>
References: <20110210.145555.39165146.davem@davemloft.net> <20110210.150759.59671055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110210.150759.59671055.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 10, 2011 at 03:07:59PM -0800, David Miller wrote:
>
> Nevermind, I turned off gso/tso on eth0 (outgoing interface) and it still
> happens.

Turning off GSO/TSO has no effect if it's GRO generating the packet
since it still has to be segmented regardless.

So I think this is the problem that you found and we need to fix it
by checking the gso_size parameter.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
