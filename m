From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: panic in leaf_walk_rcu due to stale node pointer
Date: Wed, 03 Aug 2016 12:01:43 -0700 (PDT)
Message-ID: <20160803.120143.377608139981878642.davem@davemloft.net>
References: <1470233581-25728-1-git-send-email-dforster@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com
To: dforster@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47246 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757059AbcHCTDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 15:03:10 -0400
In-Reply-To: <1470233581-25728-1-git-send-email-dforster@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Forster <dforster@brocade.com>
Date: Wed, 3 Aug 2016 15:13:01 +0100

> Panic occurs when issuing "cat /proc/net/route" whilst
> populating FIB with > 1M routes.
> 
> Use of cached node pointer in fib_route_get_idx is unsafe.
 ...
> Signed-off-by: Dave Forster <dforster@brocade.com>

Alexander, please review.

Thanks.
