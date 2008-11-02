From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add documentation for skb recycling
Date: Sat, 01 Nov 2008 21:01:18 -0700 (PDT)
Message-ID: <20081101.210118.60080241.davem@davemloft.net>
References: <20081021031732.GO4129@xi.wantstofly.org>
	<20081026.230500.268424963.davem@davemloft.net>
	<20081101025929.GA13377@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, rdunlap@xenotime.net, netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55597
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750804AbYKBEBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 00:01:43 -0400
In-Reply-To: <20081101025929.GA13377@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Sat, 1 Nov 2008 03:59:29 +0100

> On Sun, Oct 26, 2008 at 11:05:00PM -0700, David Miller wrote:
> 
> > > How about tweaking this slightly and saying:
> > > 
> > >  * 	Checks that the skb passed in is not shared or cloned, and
> > >  *	that it is linear and its head portion at least as large as
> > >  *	skb_size so that it can be recycled as a receive buffer.
> > >  * 	If these conditions are met, this function does any necessary
> > >  *	reference count dropping and cleans up the skbuff as if it
> > >  *	just came from __alloc_skb().
> > 
> > I like this tweak, someone please send me the final version with
> > proper signoffs etc.
> 
> How about this:

Applied, thanks a lot everyone.
