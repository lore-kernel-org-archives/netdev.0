From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: drop the judgement in rt6_alloc_cow()
Date: Tue, 05 Nov 2013 22:17:34 -0500 (EST)
Message-ID: <20131105.221734.996824909093482711.davem@davemloft.net>
References: <5278837D.7030207@cn.fujitsu.com>
	<20131105212344.GM8832@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: duanj.fnst@cn.fujitsu.com, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36358 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755762Ab3KFDRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 22:17:36 -0500
In-Reply-To: <20131105212344.GM8832@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 5 Nov 2013 22:23:44 +0100

> On Tue, Nov 05, 2013 at 01:34:53PM +0800, Duan Jiong wrote:
>> 
>> Now rt6_alloc_cow() is only called by ip6_pol_route() when
>> rt->rt6i_flags doesn't contain both RTF_NONEXTHOP and RTF_GATEWAY,
>> and rt->rt6i_flags hasn't been changed in ip6_rt_copy().
>> So there is no neccessary to judge whether rt->rt6i_flags contains
>> RTF_GATEWAY or not.
> 
> This is ok.
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks everyone.
