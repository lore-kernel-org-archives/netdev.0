From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] igmp: refine skb allocations
Date: Thu, 18 Nov 2010 11:02:52 -0800 (PST)
Message-ID: <20101118.110252.35044756.davem@davemloft.net>
References: <1289975802.2732.195.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45781
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757350Ab0KRTC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 14:02:27 -0500
In-Reply-To: <1289975802.2732.195.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 17 Nov 2010 07:36:42 +0100

> IGMP allocates MTU sized skbs. This may fail for large MTU (order-2
> allocations), so add a fallback to try lower sizes.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, although in the long run we need to be a lot more
intelligent here.  However, this is a good start. :-)

