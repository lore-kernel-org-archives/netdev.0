From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3 XFRM]: Fix invalid key for lookup of cached bundles
Date: Mon, 07 Mar 2005 02:41:30 +0100
Message-ID: <422BB14A.5030302@trash.net>
References: <E1D7t0w-0008Qa-00@gondolin.me.apana.org.au> <422AF8D0.3010905@trash.net> <20050307012458.GA4335@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050307012458.GA4335@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Sun, Mar 06, 2005 at 01:34:24PM +0100, Patrick McHardy wrote:
> 
>>How about this one ? It keeps the DST_XFRM_TUNNEL flag and sets it on
>>the first xfrm_dst in a bundle. I know it doesn't really belong there,
> 
> 
> Actually, why do we need to treat tunnel mode differently here?
> In other words, why not just do the mark/tos checks unconditionally.
> 
> Forwarded packets don't get a proper tos/mark setting for IPsec
> but that's a bug in itself.

Mainly to avoid excessive long lists of cached bundles in tunnel
mode. The use of a single list for the cache is questionable, but
the patch was supposed to fix a different issue. Restricting use
of tos/mark to transport mode avoids having exploding lists that
are easily remotely triggerable.

Regards
Patrick
