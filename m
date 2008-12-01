From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH 3/5] crypto: add possibility to force sync transform
Date: Mon, 1 Dec 2008 14:19:10 +0100
Message-ID: <20081201131910.GA13998@secunet.com>
References: <20081201071614.GP476@secunet.com> <20081201071903.GS476@secunet.com> <20081201112225.GA20659@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:49427 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750980AbYLANSW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 08:18:22 -0500
Content-Disposition: inline
In-Reply-To: <20081201112225.GA20659@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 07:22:25PM +0800, Herbert Xu wrote:
> 
> If you want sync algorithms, you should request for that at alloc
> time:
> 
> 	crypto_alloc_ablkcipher("foo", 0, CRYPTO_ALG_ASYNC);

Ok, will do that.

> 
> Doing so at run-time is going to end in tears.
> 

As I wrote, I'm not that familiar with the crypto system :-)
