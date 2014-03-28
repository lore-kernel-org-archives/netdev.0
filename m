From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: net: add a core netdev->tx_dropped
 counter
Date: Fri, 28 Mar 2014 16:51:07 -0400 (EDT)
Message-ID: <20140328.165107.2032068536221746348.davem@davemloft.net>
References: <1395935156.12610.295.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40793 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760AbaC1UvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 16:51:09 -0400
In-Reply-To: <1395935156.12610.295.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 Mar 2014 08:45:56 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Dropping packets in __dev_queue_xmit() when transmit queue
> is stopped (NIC TX ring buffer full or BQL limit reached) currently
> outputs a syslog message.
> 
> It would be better to get a precise count of such events available in
> netdevice stats so that monitoring tools can have a clue.
> 
> This extends the work done in caf586e5f23ce
> ("net: add a core netdev->rx_dropped counter")
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
