From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Routing local multicast datagrams
Date: Wed, 20 Apr 2005 12:06:13 +1000
Message-ID: <20050420020613.GA28085@gondor.apana.org.au>
References: <4265143D.6020406@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <linux-net-owner@vger.kernel.org>
To: Ivo Steinmann <ivo_steinmann@gmx.net>
Content-Disposition: inline
In-Reply-To: <4265143D.6020406@gmx.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 19, 2005 at 02:22:53PM +0000, Ivo Steinmann wrote:
> 
> I have got a multicast router with mrouted as multicast routing daemon. 
> As long as the multicast datagrams come from eth[x] they are routed 
> correctly to eth[y] interface. But if the datagrams come from a prozess 
> that is running on the router, they are not routed corretly by mroute.

This is a known deficiency in the Linux multicast routing code.
See comment at the top of ip_mr_forward.

Alexey, could you give us a more detailed explanation on the
problems with supporting multicast applications on multicast
routers?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
