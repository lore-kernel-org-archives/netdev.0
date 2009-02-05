From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix UDP short packet false positive
Date: Thu, 05 Feb 2009 15:06:12 -0800 (PST)
Message-ID: <20090205.150612.208352009.davem@davemloft.net>
References: <20090204.010029.12969718.davem@davemloft.net>
	<1233837840.20497.129.camel@localhost.localdomain>
	<1233838027.20497.132.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51158
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750915AbZBEXGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 18:06:17 -0500
In-Reply-To: <1233838027.20497.132.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Thu, 05 Feb 2009 13:47:07 +0100

> 
> The UDP header pointer assignment must happen after calling
> pskb_may_pull().  As pskb_may_pull() can potentially alter the SKB
> buffer.
> 
> This was exposted by running multicast traffic through the NIU driver,
> as it won't prepull the protocol headers into the linear area on
> receive.
> 
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

Excellent work!

Applied and queued up for -stable, thanks!
