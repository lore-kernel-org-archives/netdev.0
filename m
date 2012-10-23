From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v8 1/1] ipv6: add support of equal cost
 multipath (ECMP)
Date: Tue, 23 Oct 2012 02:39:10 -0400 (EDT)
Message-ID: <20121023.023910.80461258323920266.davem@davemloft.net>
References: <20121021.204146.1395047796384194358.davem@davemloft.net>
	<1350913329-4044-1-git-send-email-nicolas.dichtel@6wind.com>
	<1350913329-4044-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, bernat@luffy.cx, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, eric.dumazet@gmail.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724Ab2JWGjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 02:39:14 -0400
In-Reply-To: <1350913329-4044-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: nicolas.dichtel@6wind.com
Date: Mon, 22 Oct 2012 15:42:09 +0200

> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> Each nexthop is added like a single route in the routing table. All routes
> that have the same metric/weight and destination but not the same gateway
> are considering as ECMP routes. They are linked together, through a list called
> rt6i_siblings.
> 
> ECMP routes can be added in one shot, with RTA_MULTIPATH attribute or one after
> the other (in both case, the flag NLM_F_EXCL should not be set).
> 
> The patch is based on a previous work from
> Luc Saillard <luc.saillard@6wind.com>.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.
