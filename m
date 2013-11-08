From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: use rt6_get_dflt_router to get default router in rt6_route_rcv
Date: Fri, 8 Nov 2013 13:43:30 +0100
Message-ID: <20131108124330.GD5876@order.stressinduktion.org>
References: <527C44E5.70606@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58025 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683Ab3KHMnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 07:43:31 -0500
Content-Disposition: inline
In-Reply-To: <527C44E5.70606@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 08, 2013 at 09:56:53AM +0800, Duan Jiong wrote:
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

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
