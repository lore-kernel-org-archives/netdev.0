From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: core changes for supporting
 multiple Rx queues
Date: Mon, 09 Mar 2015 22:46:06 -0400 (EDT)
Message-ID: <20150309.224606.1211249445188258501.davem@davemloft.net>
References: <20150309204001.215FB2214B7@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbbCJCqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 22:46:08 -0400
In-Reply-To: <20150309204001.215FB2214B7@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Mon,  9 Mar 2015 13:40:00 -0700 (PDT)

> 1. Add struct bcmgenet_rx_ring to hold all necessary information
>    for a single Rx queue.
> 2. Add bcmgenet_init_rx_queues() to initialize all Rx queues.
> 3. Modify bcmgenet_init_rx_ring() to initialize a single Rx queue.
> 4. Modify Rx interrupt path code to use per-queue data.
> 5. Modify bcmgenet_rx_refill() to use RxCB->bd_addr.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Applied, thanks.
