From: David Miller <davem@davemloft.net>
Subject: Re: panic with 2.6.28 while doing "ip -6 route"
Date: Tue, 13 Jan 2009 22:17:00 -0800 (PST)
Message-ID: <20090113.221700.221763350.davem@davemloft.net>
References: <Pine.LNX.4.64.0901140204560.16420@nacho.alt.net>
	<20090114053534.GA15267@gondor.apana.org.au>
	<Pine.LNX.4.64.0901140610440.17915@nacho.alt.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: ccaputo@alt.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34804
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752329AbZANGRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 01:17:00 -0500
In-Reply-To: <Pine.LNX.4.64.0901140610440.17915@nacho.alt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Caputo <ccaputo@alt.net>
Date: Wed, 14 Jan 2009 06:15:38 +0000 (UTC)

> On Wed, 14 Jan 2009, Herbert Xu wrote:
> > I'm surprised that it's taken nearly 3 years for this bug to
> > show itself.  It even survived a move from route.c :)
> > 
> > ipv6: Fix fib6_dump_table walker leak
> > 
> > When a fib6 table dump is prematurely ended, we won't unlink
> > its walker from the list.  This causes all sorts of grief for
> > other users of the list later.
> > 
> > Reported-by: Chris Caputo <ccaputo@alt.net>
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > 
> > diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> > index 29c7c99..52ee1dc 100644
> 
> I applied the patch, rebooted and performed about a hundred "ip -6 route | 
> head" commands with the full v6 route table.  The fix works great!
> 
> Any chance of vectoring it for 2.6.28.x?

Sure, I'll queue it up for -stable.
