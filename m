From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3 XFRM]: Fix invalid key for lookup of cached bundles
Date: Mon, 07 Mar 2005 03:30:26 +0100
Message-ID: <422BBCC2.4010706@trash.net>
References: <E1D7t0w-0008Qa-00@gondolin.me.apana.org.au> <422AF8D0.3010905@trash.net> <20050307012458.GA4335@gondor.apana.org.au> <422BB14A.5030302@trash.net> <20050307014337.GA4451@gondor.apana.org.au> <422BB477.3040607@trash.net> <20050307015943.GA4533@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050307015943.GA4533@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> How about we fix the bundle problem first, and then add the fwmark/tos
> stuff? I think fixing the bundle list scalability is probably more
> important than having working TOS/fwmark at this point in time.

I agree that it is more important, but I don't see any harm in fixing
the other problem for transport mode first. Fixing the scalability
problem requires a dynamically resized hash, anything static will
lead to different scalability problems with a large number of policies.
The tos/fwmark part looks comparatively small, simply reroute all
packets based on src/dst/fwmark/predicted final tos if they differ.
But since both of this is not done yet, I think it would be better to
fix the smaller problem first.

Regards
Patrick
