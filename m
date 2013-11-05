From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: drop the judgement in rt6_alloc_cow()
Date: Tue, 5 Nov 2013 22:23:44 +0100
Message-ID: <20131105212344.GM8832@order.stressinduktion.org>
References: <5278837D.7030207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51707 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167Ab3KEVXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 16:23:46 -0500
Content-Disposition: inline
In-Reply-To: <5278837D.7030207@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 05, 2013 at 01:34:53PM +0800, Duan Jiong wrote:
> 
> Now rt6_alloc_cow() is only called by ip6_pol_route() when
> rt->rt6i_flags doesn't contain both RTF_NONEXTHOP and RTF_GATEWAY,
> and rt->rt6i_flags hasn't been changed in ip6_rt_copy().
> So there is no neccessary to judge whether rt->rt6i_flags contains
> RTF_GATEWAY or not.

This is ok.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
