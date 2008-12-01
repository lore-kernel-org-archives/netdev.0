From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH 5/5] crypto: make struct aead percpu data
Date: Mon, 1 Dec 2008 14:36:54 +0100
Message-ID: <20081201133654.GC13998@secunet.com>
References: <20081201071614.GP476@secunet.com> <20081201072043.GU476@secunet.com> <20081201114000.GB20961@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:49599 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751355AbYLANgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 08:36:08 -0500
Content-Disposition: inline
In-Reply-To: <20081201114000.GB20961@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 07:40:00PM +0800, Herbert Xu wrote:
> On Mon, Dec 01, 2008 at 08:20:43AM +0100, Steffen Klassert wrote:
> > From: Steffen Klassert <steffen.klassert@secunet.com>
> > 
> > The struct aead is now allocated as percpu data to get
> > rid of a very high contended lock in crypto_authenc_hash()
> > if IPsec runs in parallel.
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> Well you're in luck :) One of the objectives of the shash work
> is to get rid of this lock.  So instead of doing this, please
> push the shash work along and we can eliminate this without
> allocating loads of duplicate tfm's.
> 

I searched for your shash work. Is there already some work in progress
aside from crc32?
