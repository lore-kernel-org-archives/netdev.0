From: David Dillow <dave@thedillows.org>
Subject: Re: [IPSEC] Stop using dst->xfrm
Date: Sat, 22 Jan 2005 00:58:33 -0500
Message-ID: <1106373513.3691.49.camel@ori.thedillows.org>
References: <20050121102319.GA3160@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050121102319.GA3160@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-01-21 at 21:23 +1100, Herbert Xu wrote:

> Here is a precursor to the xfrm dst consolidation that I talked about.
> In order to be able to store multiple SAs in one dst, we need to stop
> using dst->xfrm directly.

Can you tell me more about this? A quick search of google and the netdev
archives didn't turn up anything that looked relevant.

I'd like to see where you're going, so I can meet you there. The xfrm
offload patches currently add dst->xfrm_offload to cache the info needed
to offload the crypto operations. It'll be slower, but I could lookup
that up each time if need be.

The part I'm most curious about is the storing of multiple SAs in one
dst, since I think may cause the most changes for me. I'd like to start
thinking about them early.
-- 
David Dillow <dave@thedillows.org>
