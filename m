From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: Fix potential wrong ip_hdr(skb) pointers
Date: Fri, 06 Feb 2009 01:59:35 -0800 (PST)
Message-ID: <20090206.015935.60090330.davem@davemloft.net>
References: <1233910824.21135.6.camel@localhost.localdomain>
	<20090206.010824.99072382.davem@davemloft.net>
	<1233914158.21135.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50573
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752249AbZBFJ7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 04:59:39 -0500
In-Reply-To: <1233914158.21135.11.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Fri, 06 Feb 2009 10:55:58 +0100

> On Fri, 2009-02-06 at 01:08 -0800, David Miller wrote:
> > Please respin this patch of your's with proper commit message
> > and signoffs, thanks!
> 
> Like the UDP header fix, pskb_may_pull() can potentially
> alter the SKB buffer.  Thus the saddr and daddr, pointers
> may point to the old skb->data buffer.
> 
> I haven't seen corruptions, as its only seen if the old
> skb->data buffer were reallocated by another user and
> written into very quickly (or poison'd by SLAB debugging).
> 
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

Applied, thanks!
