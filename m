From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3 XFRM]: Fix invalid key for lookup of cached bundles
Date: Mon, 07 Mar 2005 04:11:17 +0100
Message-ID: <422BC655.5070907@trash.net>
References: <E1D7t0w-0008Qa-00@gondolin.me.apana.org.au> <422AF8D0.3010905@trash.net> <20050307012458.GA4335@gondor.apana.org.au> <422BB14A.5030302@trash.net> <20050307014337.GA4451@gondor.apana.org.au> <422BB477.3040607@trash.net> <20050307015943.GA4533@gondor.apana.org.au> <422BBCC2.4010706@trash.net> <20050307025723.GA4818@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050307025723.GA4818@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> The reason I'm asking is because the places where you're most likely
> to use tos/fwmark is in IPsec gateways.  In other words, it isn't
> very useful unless it works in tunnel mode.  This plus the fact
> that the check for tunnel mode is a bit of a hack makes me think that
> it's not worth it at the moment.

Ok, let's drop it for now. One of my reasons for fixing it was that it
gives clearly defined behaviour, which makes it easier for me to make
sure the changes I made for xfrm resolution are correct. I'm simply
going to assume it will be working correctly sometime.

> On the subject of fixing the scalability issue, we should just use
> the flow cache directly for each bundle.

Let me think about it.

Regards
Patrick
