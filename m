From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6]: keep fragment queues private to each user
Date: Wed, 26 Jan 2005 07:47:28 +1100
Message-ID: <20050125204728.GA23939@gondor.apana.org.au>
References: <E1CtPJf-0005RG-00@gondolin.me.apana.org.au> <41F65A80.70808@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41F65A80.70808@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jan 25, 2005 at 03:41:04PM +0100, Patrick McHardy wrote:
>
> deal with them, but it is pretty tricky to get right. For different
> interfaces: I'm not exactly sure where this is a problem, except
> that any classification will only look at the head fragment interface.

Well consider an IPIP interface over a transport mode ESP SA...
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
