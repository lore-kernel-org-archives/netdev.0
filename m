From: David Miller <davem@davemloft.net>
Subject: Re: panic with 2.6.28 while doing "ip -6 route"
Date: Tue, 13 Jan 2009 22:18:27 -0800 (PST)
Message-ID: <20090113.221827.18575276.davem@davemloft.net>
References: <Pine.LNX.4.64.0901140204560.16420@nacho.alt.net>
	<20090114053534.GA15267@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ccaputo@alt.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41522
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752387AbZANGS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 01:18:26 -0500
In-Reply-To: <20090114053534.GA15267@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 14 Jan 2009 16:35:34 +1100

> ipv6: Fix fib6_dump_table walker leak
> 
> When a fib6 table dump is prematurely ended, we won't unlink
> its walker from the list.  This causes all sorts of grief for
> other users of the list later.
> 
> Reported-by: Chris Caputo <ccaputo@alt.net>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks for fixing this
bug Herbert.
