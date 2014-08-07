From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: IEEE fixes for DCBx state machine
Date: Thu, 07 Aug 2014 16:01:13 -0700 (PDT)
Message-ID: <20140807.160113.1118554897109315806.davem@davemloft.net>
References: <1407442256-7308-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, leedom@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbaHGXBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 19:01:18 -0400
In-Reply-To: <1407442256-7308-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Thu,  7 Aug 2014 13:10:56 -0700

> +	netdev_info(dev, "%s: Initializing DCB state for port[%d]\n",
> +		    __func__, pi->port_id);
 ...
> +	netdev_info(dev, "%s: State change from %d to %d for %s\n",
> +		    __func__, dcb->state, transition_to, dev->name);

These logging messages look excessive, especially at KERN_INFO logging
level.

Either remove them or make them _dbg() or similar.
