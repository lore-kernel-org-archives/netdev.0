From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: export netdev_stats_to_stats64
Date: Mon, 05 Mar 2012 15:40:29 -0500 (EST)
Message-ID: <20120305.154029.2036437171847433536.davem@davemloft.net>
References: <1330954326.2474.9.camel@edumazet-laptop>
	<1330955921.2474.18.camel@edumazet-laptop>
	<1330959009.2474.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, junchangwang@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932357Ab2CEUkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 15:40:33 -0500
In-Reply-To: <1330959009.2474.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 05 Mar 2012 06:50:09 -0800

> Some drivers use internal netdev stats member to store part of their
> stats, yet advertize ndo_get_stats64() to implement some 64bit fields.
> 
> Allow them to use netdev_stats_to_stats64() helper to make the copy of
> netdev stats before they compute their 64bit counters.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
