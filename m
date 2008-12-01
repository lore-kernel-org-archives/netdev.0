From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH 4/5] crypto: allow allocation of percpu crypto
	transforms
Date: Mon, 1 Dec 2008 14:21:50 +0100
Message-ID: <20081201132150.GB13998@secunet.com>
References: <20081201071614.GP476@secunet.com> <20081201071943.GT476@secunet.com> <20081201113828.GA20961@gondor.apana.org.au> <20081201.042502.223043756.davem@davemloft.net> <20081201123859.GA21424@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:49451 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750833AbYLANVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 08:21:03 -0500
Content-Disposition: inline
In-Reply-To: <20081201123859.GA21424@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 08:38:59PM +0800, Herbert Xu wrote:
> On Mon, Dec 01, 2008 at 04:25:02AM -0800, David Miller wrote:
> >
> > If, in those changes, I was removing atomics to make rule insert and
> > delete faster, making more TFM allocs happen might be a big no-no :)
> 
> Fair enough.  But it looks like this stuff only exists because of
> the spinlock on the hash which shash will get rid of anyway.
> 

Yes exactly, it was just to get rid of the lock.
