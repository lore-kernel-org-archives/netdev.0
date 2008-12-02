From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH 0/5] IPsec parallelization
Date: Tue, 2 Dec 2008 10:39:11 +0100
Message-ID: <20081202093911.GH13998@secunet.com>
References: <20081201071614.GP476@secunet.com> <20081201084902.GA19904@gondor.apana.org.au> <20081201.022929.253639406.davem@davemloft.net> <20081201111501.GA20650@gondor.apana.org.au> <20081202075804.GD13998@secunet.com> <20081202081948.GA30063@gondor.apana.org.au> <20081202084419.GF13998@secunet.com> <20081202085325.GA30353@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:55508 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751399AbYLBJiX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 04:38:23 -0500
Content-Disposition: inline
In-Reply-To: <20081202085325.GA30353@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 02, 2008 at 04:53:25PM +0800, Herbert Xu wrote:
> On Tue, Dec 02, 2008 at 09:44:19AM +0100, Steffen Klassert wrote:
> >
> > > 3) The same mechanism can benefit other crypto users such as
> > > disk encryption.
> > 
> > The padata stuff is generic, so it can be used even for disk
> > encryption or for anything else that should run in parallel but
> > needs a certain order at a given point.
> 
> The padata stuff might be great, but does that mean that we really
> want to reimplement exactly the same logic in two different places
> when we can do it just once in the crypto layer (which could also
> use padata as you suggested)?
> 

I would not mind to move the padata hooks to the crypto layer.

But what's with the interface? Should it be moved to the crypto
layer too? I'm not sure, but perhaps it could find users beyond
the crypto layer.

