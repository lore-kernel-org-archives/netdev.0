From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/3] xfrm: Increase the garbage collector threshold
Date: Fri, 13 Dec 2013 11:12:03 +0100
Message-ID: <20131213101203.GO31491@secunet.com>
References: <1383294107-7509-1-git-send-email-steffen.klassert@secunet.com>
 <1383294107-7509-3-git-send-email-steffen.klassert@secunet.com>
 <1386686323.22947.26.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46979 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752027Ab3LMKMG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 05:12:06 -0500
Content-Disposition: inline
In-Reply-To: <1386686323.22947.26.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 03:38:43PM +0100, Maxime Bizon wrote:
> 
> On Fri, 2013-11-01 at 09:21 +0100, Steffen Klassert wrote:
> 
> Hello Steffen,
> 
> > It turned out that the current threshold before we
> > start garbage collecting is much to small for some
> > workloads, so increase it from 1024 to 32768. This
> > means that we start the garbage collector if we have
> > more than 32768 dst entries in the system and refuse
> > new allocations if we are above 65536.
> 
> sorry to dig an old thread, but could you please explain the lifetime of
> those dst entries ?
> 
> After basic tests it seems the ipv4 dst entry needs to be released first
> before the xfrm dst can be released by gc.
> 

Can you please be a bit more precise with your problem description?

This patch changes only the number of cache entries before
we start garbage collecting. It does not change anything
on the garbage collector itself.
