From: David Miller <davem@davemloft.net>
Subject: Re: XFRM structures binary compability
Date: Mon, 26 Jan 2009 21:14:41 -0800 (PST)
Message-ID: <20090126.211441.74826251.davem@davemloft.net>
References: <200901161440.3616@centrum.cz>
	<20090117112707.GA7673@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klimes@centrum.cz, kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46189
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751354AbZA0FOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 00:14:44 -0500
In-Reply-To: <20090117112707.GA7673@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 17 Jan 2009 22:27:07 +1100

> Jiri Klimes <klimes@centrum.cz> wrote:
> >
> > I see no solution to obtain 32/64-bit compatibility without impacting anybody :-(
> 
> We could create new requests, e.g. NEWSA2 that can then take
> a properly designed structure which is invariant.
> 
> After that we can migrate the applications across.

I don't see anyone rushing to implement this, I guess that shows
how much it matters. :-)

> Of course for all new structures we should be doubly sure that
> they're all invariant to prevent this from happening again.

And this is true regardless of the above.
