From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: use rt6_get_dflt_router to get default router in
 rt6_route_rcv
Date: Fri, 08 Nov 2013 15:18:38 -0500 (EST)
Message-ID: <20131108.151838.396871634708278992.davem@davemloft.net>
References: <527C44E5.70606@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757437Ab3KHUSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 15:18:41 -0500
In-Reply-To: <527C44E5.70606@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Fri, 08 Nov 2013 09:56:53 +0800

> 
> As the rfc 4191 said, the Router Preference and Lifetime values in a
> ::/0 Route Information Option should override the preference and lifetime
> values in the Router Advertisement header. But when the kernel deals with
> a ::/0 Route Information Option, the rt6_get_route_info() always return
> NULL, that means that overriding will not happen, because those default
> routers were added without flag RTF_ROUTEINFO in rt6_add_dflt_router().
> 
> In order to deal with that condition, we should call rt6_get_dflt_router
> when the prefix length is 0.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied and queued up for -stable, thanks!
