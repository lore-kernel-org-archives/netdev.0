From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Namespaces and inetpeer
Date: Mon, 12 Mar 2012 10:58:40 +0100
Message-ID: <20120312095840.GM15404@secunet.com>
References: <20120310132529.GA3631@gondor.apana.org.au>
 <20120312085756.GL15404@secunet.com>
 <20120312.023505.2024370184180125281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:40386 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865Ab2CLJ6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 05:58:48 -0400
Content-Disposition: inline
In-Reply-To: <20120312.023505.2024370184180125281.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 12, 2012 at 02:35:05AM -0700, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Mon, 12 Mar 2012 09:57:56 +0100
> 
> > On Sun, Mar 11, 2012 at 12:25:29AM +1100, Herbert Xu wrote:
> >> Hi:
> >> 
> >> While looking through the inetpeer code I noticed that there is
> >> no namespace support at all.  This means that metric and other
> >> information will be leaking across namespaces.  As IP addresses
> >> are meant to be independent between them, this is not a good thing.
> >> 
> > 
> > Actually, it would be nice if we could have an inetpeer base per
> > fib table. This would imply namespace awareness and it would
> > handle the problem when we have mulitiple routes (with different
> > metrics etc.) to the same ip address on policy routing.
> 
> Then you will ask for one per security policy too, to handle IPSEC.

Hm, I don't see why this would be needed too.

It was just an idea to handle the metrcis with policy routing.
Better ideas are very welcome of course :)
