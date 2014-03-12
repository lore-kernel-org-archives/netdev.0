From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6 net-next 00/31] Misc. fixes for cxgb4 and iw_cxgb4
Date: Wed, 12 Mar 2014 15:51:25 -0400 (EDT)
Message-ID: <20140312.155125.1045693666130935765.davem@davemloft.net>
References: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbaCLTv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 15:51:27 -0400
In-Reply-To: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 12 Mar 2014 21:20:15 +0530

> V6:
>    In patch 8/31, move the existing neigh_release() call right before the
>    if(!e) test, that way you don't need a completely new label and code block
>    to fix this bug - thanks to review by David Miller
>    In patch 15/31, use %pad to print dma_addr - thanks to review by Joe Perches
>    In patch 10/31, add the "STOPPED" state string to db_state_str - thanks
>    to review by Steve Wise
>    In patch 10/31, t4_db_dropped() needs to disable dbs and send DB_FULL
>    event to iw_cxgb4 - thanks to review by Steve Wise
> V5:
>    Dropped patch "cxgb4: use spinlock_irqsave/spinlock_irqrestore for db lock".

I do not see the spinlock patch reinstated, part of it was correct and
fixed a real bug.  For the second time, I only stated that parts of it
were superfluous, not all of it.

This is becomming beyond tiring.
