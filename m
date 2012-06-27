From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skb_free_datagram_locked() doesnt drop
 all packets
Date: Wed, 27 Jun 2012 15:42:49 -0700 (PDT)
Message-ID: <20120627.154249.1708237703176021200.davem@davemloft.net>
References: <1340792624.26242.75.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47790 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757101Ab2F0Wmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 18:42:50 -0400
In-Reply-To: <1340792624.26242.75.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Jun 2012 12:23:44 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> dropwatch wrongly diagnose all received UDP packets as drops.
> 
> This patch removes trace_kfree_skb() done in skb_free_datagram_locked().
> 
> Locations calling skb_free_datagram_locked() should do it on their own.
> 
> As a result, drops are accounted on the right function.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
