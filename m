From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 2/3] net/mlx4_en: Fixing TX queue stop/wake flow
Date: Fri, 03 Aug 2012 16:49:59 -0700 (PDT)
Message-ID: <20120803.164959.1852290857085579847.davem@davemloft.net>
References: <1343990318-10744-1-git-send-email-yevgenyp@mellanox.co.il>
	<1343990318-10744-3-git-send-email-yevgenyp@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41678 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754055Ab2HCXuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 19:50:00 -0400
In-Reply-To: <1343990318-10744-3-git-send-email-yevgenyp@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Fri,  3 Aug 2012 13:38:37 +0300

> Removing the ring->blocked flag, it is redundant and leads to a race:
> 
> We close the TX queue and then set the "blocked" flag.
> Between those 2 operations the completion function can check the "blocked"
> flag, sees that it is 0, and wouldn't open the TX queue.
> 
> Using netif_tx_queue_stopped to check the state of the queue to avoid this race.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
