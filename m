From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6]: keep fragment queues private to each user
Date: Tue, 25 Jan 2005 22:57:03 +1100
Message-ID: <E1CtPJf-0005RG-00@gondolin.me.apana.org.au>
References: <41F5D1CB.9050804@trash.net>
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kaber@trash.net (Patrick McHardy)
In-Reply-To: <41F5D1CB.9050804@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote:
> 
> This patch keeps fragment queues private to each ip_defrag user to avoid
> skbs jumping between different callers. It shouldn't change any wanted
> behaviour, the only questionable one was ip_call_ra_chain, but the RA
> option is included in each fragment. If you're fine with the patch I'm going
> to send a 2.4 version later.

Patch looks good.

However, I think this is still not enough.  What about fragments
that come from different interfaces? Fragments with different
security paths?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
