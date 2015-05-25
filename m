From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 -next] ip: reject too-big defragmented DF-skb when
 forwarding
Date: Mon, 25 May 2015 00:09:40 -0400 (EDT)
Message-ID: <20150525.000940.93491597643033970.davem@davemloft.net>
References: <1432246000-11104-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbbEYEJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 00:09:44 -0400
In-Reply-To: <1432246000-11104-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 22 May 2015 00:06:40 +0200

> Send icmp pmtu error if we find that the largest fragment of df-skb
> exceeded the output path mtu.
> 
> The ip output path will still catch this later on but we can avoid the
> forward/postrouting hook traversal by rejecting right away.
> 
> This is what ipv6 already does.
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thank you.
