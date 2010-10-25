From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rps: add __rcu annotations
Date: Mon, 25 Oct 2010 14:19:27 -0700 (PDT)
Message-ID: <20101025.141927.15256378.davem@davemloft.net>
References: <1288011722.2826.116.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48799
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754018Ab0JYVTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 17:19:04 -0400
In-Reply-To: <1288011722.2826.116.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 Oct 2010 15:02:02 +0200

> Add __rcu annotations to :
> 	(struct netdev_rx_queue)->rps_map
> 	(struct netdev_rx_queue)->rps_flow_table
> 	struct rps_sock_flow_table *rps_sock_flow_table;
> 
> And use appropriate rcu primitives.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
