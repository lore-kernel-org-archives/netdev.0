From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] Stop using dst->xfrm
Date: Wed, 26 Jan 2005 18:21:04 +1100
Message-ID: <E1CthU8-0001Uo-00@gondolin.me.apana.org.au>
References: <1106373513.3691.49.camel@ori.thedillows.org>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dave@thedillows.org (David Dillow)
In-Reply-To: <1106373513.3691.49.camel@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Dillow <dave@thedillows.org> wrote:
> 
>> Here is a precursor to the xfrm dst consolidation that I talked about.
>> In order to be able to store multiple SAs in one dst, we need to stop
>> using dst->xfrm directly.
> 
> Can you tell me more about this? A quick search of google and the netdev
> archives didn't turn up anything that looked relevant.

My immediate goal is to store PMTU values for xfrm dst entries.

I was toying with the idea of consolidating the xfrm dst's of a bundle
into a single dst.  The rationale is that the current list of xfrm
dst's doesn't provide any more info than what we would have in a single
xfrm dst.

However, this is not central to my plans so I won't pursue it
straight away.

> I'd like to see where you're going, so I can meet you there. The xfrm
> offload patches currently add dst->xfrm_offload to cache the info needed
> to offload the crypto operations. It'll be slower, but I could lookup
> that up each time if need be.

I'll take a look at your work first and get back to you.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
