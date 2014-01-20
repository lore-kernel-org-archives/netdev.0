From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: optimize link local address search
Date: Sun, 19 Jan 2014 19:56:19 -0800 (PST)
Message-ID: <20140119.195619.1026706031576275995.davem@davemloft.net>
References: <20140119205819.GD16462@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brian.haley@hp.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752757AbaATD4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 22:56:20 -0500
In-Reply-To: <20140119205819.GD16462@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 19 Jan 2014 21:58:19 +0100

> ipv6_link_dev_addr sorts newly added addresses by scope in
> ifp->addr_list. Smaller scope addresses are added to the tail of the
> list. Use this fact to iterate in reverse over addr_list and break out
> as soon as a higher scoped one showes up, so we can spare some cycles
> on machines with lot's of addresses.
> 
> The ordering of the addresses is not relevant and we are more likely to
> get the eui64 generated address with this change anyway.
> 
> Suggested-by: Brian Haley <brian.haley@hp.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
