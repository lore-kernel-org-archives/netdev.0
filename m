From: David Miller <davem@davemloft.net>
Subject: Re: RCU'ed dst_get_neighbour()
Date: Tue, 29 Nov 2011 18:24:41 -0500 (EST)
Message-ID: <20111129.182441.956675970003939556.davem@davemloft.net>
References: <1322606542.2596.43.camel@edumazet-laptop>
	<alpine.WNT.2.00.1111291600220.228@TSI>
	<1322608261.2596.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tsi@ualberta.ca, roland@kernel.org, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44453 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756571Ab1K2XYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 18:24:48 -0500
In-Reply-To: <1322608261.2596.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Nov 2011 00:11:01 +0100

> For example, recently added skb_update_prio() is buggy, since it uses
> rcu_dereference() while its caller, dev_queue_xmit() called
> rcu_read_lock_bh()

We have a fixed queued up for that from Igor, I'll apply that right now.
