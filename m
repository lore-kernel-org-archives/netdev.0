From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: validate_xmit_skb() changes
Date: Thu, 14 Apr 2016 21:38:10 -0400 (EDT)
Message-ID: <20160414.213810.1210978831528706361.davem@davemloft.net>
References: <1460523007.32504.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbcDOBiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 21:38:12 -0400
In-Reply-To: <1460523007.32504.13.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 12 Apr 2016 21:50:07 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> skbs given to validate_xmit_skb() should not have a next
> pointer anymore.
> 
> Also if a packet is dropped, increment dev->tx_dropped
> __dev_queue_xmit() no longer has to change tx_dropped in this case.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
