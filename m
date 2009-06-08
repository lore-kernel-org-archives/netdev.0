From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 2/4] udp: Handle large UFO packets from
	untrusted sources
Date: Tue, 9 Jun 2009 09:37:39 +1000
Message-ID: <20090608233739.GA1021@gondor.apana.org.au>
References: <1244247391.1526.171.camel@w-sridhar.beaverton.ibm.com> <20090608051608.GA19748@gondor.apana.org.au> <1244480687.18220.36.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kvm@vger.kernel.org,
	rusty@rustcorp.com.au
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1244480687.18220.36.camel@w-sridhar.beaverton.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 08, 2009 at 10:04:47AM -0700, Sridhar Samudrala wrote:
>
> OK. Can we use skb_segment() to do IP fragmentation of UDP packets?

It should be able to.

> The function itself looks protocol independent and if it is simply
> splitting large skb into a list of mtu sized skb's, can we fixup the
> ip header differently for UDP packets(id and frag_off) in inet_gso_segment
> and ipv6_gso_segment?

Yes that's the idea.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
