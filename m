From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: Optimize local checksum offload
Date: Thu, 18 Feb 2016 15:29:43 -0500 (EST)
Message-ID: <20160218.152943.1817919033060980651.davem@davemloft.net>
References: <20160217192355.11040.3502.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947532AbcBRU3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 15:29:45 -0500
In-Reply-To: <20160217192355.11040.3502.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Wed, 17 Feb 2016 11:23:55 -0800

> This patch takes advantage of several assumptions we can make about the
> headers of the frame in order to reduce overall processing overhead for
> computing the outer header checksum.
> 
> First we can assume the entire header is in the region pointed to by
> skb->head as this is what csum_start is based on.
> 
> Second, as a result of our first assumption, we can just call csum_partial
> instead of making a call to skb_checksum which would end up having to
> configure things so that we could walk through the frags list.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Applied, thanks Alex.
