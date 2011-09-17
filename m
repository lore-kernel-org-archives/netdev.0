From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: don't use inetpeer to store metrics for routes.
Date: Sat, 17 Sep 2011 00:57:46 -0400 (EDT)
Message-ID: <20110917.005746.1228785589532886752.davem@davemloft.net>
References: <4E65CD06.2080903@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: zheng.z.yan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab1IQE5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 00:57:51 -0400
In-Reply-To: <4E65CD06.2080903@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yan, Zheng" <zheng.z.yan@intel.com>
Date: Tue, 06 Sep 2011 15:34:30 +0800

> Current IPv6 implementation uses inetpeer to store metrics for
> routes. The problem of inetpeer is that it doesn't take subnet
> prefix length in to consideration. If two routes have the same
> address but different prefix length, they share same inetpeer.
> So changing metrics of one route also affects the other. The
> fix is to allocate separate metrics storage for each route.
> 
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>

Applied, thanks for fixing this bug.
