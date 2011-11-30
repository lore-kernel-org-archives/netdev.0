From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/10] sfc: Support for byte queue limits
Date: Wed, 30 Nov 2011 17:12:39 -0500 (EST)
Message-ID: <20111130.171239.236955684775039413.davem@davemloft.net>
References: <alpine.DEB.2.00.1111281822060.23687@pokey.mtv.corp.google.com>
	<1322657043.2403.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55985 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457Ab1K3WMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 17:12:43 -0500
In-Reply-To: <1322657043.2403.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Nov 2011 13:44:03 +0100

> [PATCH net-next] sfc: fix race in efx_enqueue_skb_tso()
> 
> As soon as skb is pushed to hardware, it can be completed and freed, so
> we should not dereference skb anymore.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
