From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: remove the unnecessary statement in find_match()
Date: Fri, 01 Nov 2013 18:08:18 -0400 (EDT)
Message-ID: <20131101.180818.259804474193048469.davem@davemloft.net>
References: <5271F263.4020800@cn.fujitsu.com>
	<20131031084537.GA17210@order.stressinduktion.org>
	<52723A84.9080308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756329Ab3KAWIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 18:08:20 -0400
In-Reply-To: <52723A84.9080308@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Thu, 31 Oct 2013 19:09:56 +0800

> Removing CONFIG_IPV6_ROUTER_PREF means that the Router Preference is
> always on, is this understanding right?
> 
> If that's is correct, i think compatibility issues will arise. For
> example, when the CONFIG_IPV6_ROUTER_PREF option is on, the kernel
> should not do round-robin during default router selection, but when
> the CONFIG_IPV6_ROUTER_PREF option is off, the kernel should do it.

Everyone is essentially getting it enabled right now anyways, since
%99.999999 of users run distribution kernels.  Nobody has asked
for a run-time knob for this, which therefore means that %99.999999
of users simply do not care.

Yes there are people who build their own kernels, but to tell you
the truth I doubt anyone really turns this off explicitly to turn
off router preference handling.

But I'm willing to cater to them _iff_ the RFC tells us we should
provide should a capability.
