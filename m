From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Set mcast_hops to IPV6_DEFAULT_MCASTHOPS when -1
 was given.
Date: Mon, 28 Nov 2011 18:09:35 -0500 (EST)
Message-ID: <20111128.180935.774474803377807469.davem@davemloft.net>
References: <4ED3394E.7050602@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471Ab1K1XJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 18:09:43 -0500
In-Reply-To: <4ED3394E.7050602@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Mon, 28 Nov 2011 15:33:34 +0800

> We need to set np->mcast_hops to it's default value at this moment
> otherwise when we use it and found it's value is -1, the logic to
> get default hop limit doesn't take multicast into account and will
> return wrong hop limit(IPV6_DEFAULT_HOPLIMIT) which is for unicast.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

Applied, thank you.
