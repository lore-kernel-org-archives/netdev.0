From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4/route/rtnl: get mcast attributes when dst is
 multicast
Date: Fri, 07 Dec 2012 12:25:07 -0500 (EST)
Message-ID: <20121207.122507.541861041360995953.davem@davemloft.net>
References: <1354618987-15794-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755105Ab2LGRZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 12:25:12 -0500
In-Reply-To: <1354618987-15794-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue,  4 Dec 2012 12:03:07 +0100

> Commit f1ce3062c538 (ipv4: Remove 'rt_dst' from 'struct rtable') removes the
> call to ipmr_get_route(), which will get multicast parameters of the route.
> 
> I revert the part of the patch that remove this call. I think the goal was only
> to get rid of rt_dst field.
> 
> The patch is only compiled-tested. My first idea was to remove ipmr_get_route()
> because rt_fill_info() was the only user, but it seems the previous patch cleans
> the code a bit too much ;-)
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Good catch, applied to net-next.

Thanks.
