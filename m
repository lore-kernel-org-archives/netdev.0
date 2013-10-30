From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: remove the unnecessary statement in find_match()
Date: Wed, 30 Oct 2013 10:44:12 +0100
Message-ID: <20131030094412.GA24479@order.stressinduktion.org>
References: <5270B7AE.9020801@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38176 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750Ab3J3JoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 05:44:13 -0400
Content-Disposition: inline
In-Reply-To: <5270B7AE.9020801@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 30, 2013 at 03:39:26PM +0800, Duan Jiong wrote:
> 
> After reading the function rt6_check_neigh(), we can
> know that the RT6_NUD_FAIL_SOFT can be returned only
> when the IS_ENABLE(CONFIG_IPV6_ROUTER_PREF) is false.
> so in function find_match(), there is no need to execute
> the statement !IS_ENABLED(CONFIG_IPV6_ROUTER_PREF).

It should be constant folded away. But I agree, we can remove this:

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
