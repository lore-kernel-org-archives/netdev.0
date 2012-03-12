From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Namespaces and inetpeer
Date: Mon, 12 Mar 2012 09:57:56 +0100
Message-ID: <20120312085756.GL15404@secunet.com>
References: <20120310132529.GA3631@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39336 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752793Ab2CLI57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 04:57:59 -0400
Content-Disposition: inline
In-Reply-To: <20120310132529.GA3631@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 11, 2012 at 12:25:29AM +1100, Herbert Xu wrote:
> Hi:
> 
> While looking through the inetpeer code I noticed that there is
> no namespace support at all.  This means that metric and other
> information will be leaking across namespaces.  As IP addresses
> are meant to be independent between them, this is not a good thing.
> 

Actually, it would be nice if we could have an inetpeer base per
fib table. This would imply namespace awareness and it would
handle the problem when we have mulitiple routes (with different
metrics etc.) to the same ip address on policy routing.
