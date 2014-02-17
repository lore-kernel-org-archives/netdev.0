From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix counter in_slow_tot
Date: Mon, 17 Feb 2014 16:55:10 -0500 (EST)
Message-ID: <20140217.165510.2229610155761716628.davem@davemloft.net>
References: <5301B8FF.6030800@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbaBQVzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 16:55:12 -0500
In-Reply-To: <5301B8FF.6030800@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Mon, 17 Feb 2014 15:23:43 +0800

> since commit 89aef8921bf("ipv4: Delete routing cache."), the counter
> in_slow_tot can't work correctly.
> 
> The counter in_slow_tot increase by one when fib_lookup() return successfully
> in ip_route_input_slow(), but actually the dst struct maybe not be created and
> cached, so we can increase in_slow_tot after the dst struct is created.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied and queued up for -stable, thanks.
