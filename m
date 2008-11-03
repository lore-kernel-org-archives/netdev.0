From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] Fix ESP SA loading (by default)
Date: Mon, 3 Nov 2008 03:16:43 +0300
Message-ID: <20081103001643.GA22217@x200.localdomain>
References: <20081101050458.GA17807@gondor.apana.org.au> <20081101113835.GA3127@x200.localdomain> <20081101115043.GA19593@gondor.apana.org.au> <20081101.213315.01349801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:50627 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928AbYKCANb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 19:13:31 -0500
Received: by ey-out-2122.google.com with SMTP id 6so758678eyi.37
        for <netdev@vger.kernel.org>; Sun, 02 Nov 2008 16:13:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081101.213315.01349801.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 01, 2008 at 09:33:15PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sat, 1 Nov 2008 19:50:43 +0800
> 
> > On Sat, Nov 01, 2008 at 02:38:35PM +0300, Alexey Dobriyan wrote:
> > >
> > > It's a cut down example. This won't work either:
> > 
> > OK, in that case I suggest we make AH depend on the null algorithms
> > instead.  This is because very few people use AH these days and only
> > they need this.
> 
> One could even argue that we should blow away all of those select
> statements.

Keep in mind that the only error message is "line N: returned (null)"
from setkey(8) or something like that and no SA created.

It took me full printk session to realize what's going on.
