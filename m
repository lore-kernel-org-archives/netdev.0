From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: 3com: fix warning for incorrect type
 in argument
Date: Mon, 13 Jan 2014 23:31:10 -0800 (PST)
Message-ID: <20140113.233110.1828368771962242601.davem@davemloft.net>
References: <52D0FF89.2020206@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com, julia.lawall@lip6.fr
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbaANHbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 02:31:11 -0500
In-Reply-To: <52D0FF89.2020206@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Sat, 11 Jan 2014 16:23:37 +0800

> The commit c466a9b2b329f7d9982c14eedc83a923d3bc711c
> (net: 3com: slight optimization of addr compare)
> cause a warning: "passing argument 1 of 'ether_addr_equal'
> from incompatible pointer type", so fix it.
> 
> I think julia will convert ether_addr_equal to ether_addr_equal_64bits later.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied.
