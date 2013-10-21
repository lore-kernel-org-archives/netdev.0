From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: probe routes asynchronous in rt6_probe
Date: Mon, 21 Oct 2013 18:57:30 -0400 (EDT)
Message-ID: <20131021.185730.1660389371253610827.davem@davemloft.net>
References: <20131021041715.GH27787@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934Ab3JUW5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 18:57:32 -0400
In-Reply-To: <20131021041715.GH27787@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 21 Oct 2013 06:17:15 +0200

> Routes need to be probed asynchronous otherwise the call stack gets
> exhausted when the kernel attemps to deliver another skb inline, like
> e.g. xt_TEE does, and we probe at the same time.
> 
> We update neigh->updated still at once, otherwise we would send to
> many probes.
> 
> Cc: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks good, applied and queued up for -stable, thanks Hannes.
