From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next-2.6] net/ipv4: push IP options to CB in
	ip_fragment
Date: Thu, 2 Sep 2010 07:30:56 +0800
Message-ID: <20100901233056.GA15177@gondor.apana.org.au>
References: <1283204118.2405.32.camel@edumazet-laptop> <20100830232147.GB10754@stratus.com> <1283232031.2405.38.camel@edumazet-laptop> <20100901.144658.135972233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, bandan.das@stratus.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100901.144658.135972233.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 01, 2010 at 02:46:58PM -0700, David Miller wrote:
.
> Therefore I'm inclined to agree with Herbert that we need to parse the
> options explicitly before invoke ip_fragment().  We must call it with
> an SKB in the state it expects, and that means with options parsing
> already performed.

FWIW the packet probably doesn't even have IP options.  What is
happening here is that we've found yet another entry point from
the bridge driver into the IP stack so we need to duplicate my
original patch here.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
