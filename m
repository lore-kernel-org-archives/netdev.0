From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: remove the unnecessary statement in find_match()
Date: Wed, 30 Oct 2013 17:08:37 -0400 (EDT)
Message-ID: <20131030.170837.1882918923249091614.davem@davemloft.net>
References: <5270B7AE.9020801@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996Ab3J3VIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 17:08:38 -0400
In-Reply-To: <5270B7AE.9020801@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Wed, 30 Oct 2013 15:39:26 +0800

> 
> After reading the function rt6_check_neigh(), we can
> know that the RT6_NUD_FAIL_SOFT can be returned only
> when the IS_ENABLE(CONFIG_IPV6_ROUTER_PREF) is false.
> so in function find_match(), there is no need to execute
> the statement !IS_ENABLED(CONFIG_IPV6_ROUTER_PREF).
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied to net-next, thanks.

CONFIG_IPV6_ROUTER_PREF is another good candidate for Kconfig
removal.  I know we've had several bugs that only apply when
this option is on vs. off.  We're maintaining two different
code paths, for really no good reason.
