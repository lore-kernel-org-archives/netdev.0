From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: remove unnecessory call
 rt6_clean_expires
Date: Thu, 20 Sep 2012 01:03:09 -0400 (EDT)
Message-ID: <20120920.010309.616282450923974496.davem@davemloft.net>
References: <1348117053-4113-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gaofeng@cn.fujitsu.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005Ab2ITFDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 01:03:11 -0400
In-Reply-To: <1348117053-4113-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 20 Sep 2012 12:57:33 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> ip6_dst_alloc will zero the from and rt6i_flags of dst cache,
> so it is unnecessory to call rt6_clean_expires again.
> 
> Cc: Gao feng <gaofeng@cn.fujitsu.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

You're modifying ip6_blackhole_route() and ip6_route_add().

Only the latter calls ip6_dst_alloc().

I know the change is OK, but your commit message is extremely
inaccurate, please fix it.
