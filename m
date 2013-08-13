From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xfrm: introduce helper for safe determination of
 mtu
Date: Tue, 13 Aug 2013 16:39:08 -0700 (PDT)
Message-ID: <20130813.163908.1554594022630686619.davem@davemloft.net>
References: <20130813023558.GD27385@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45462 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755311Ab3HMXjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 19:39:09 -0400
In-Reply-To: <20130813023558.GD27385@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 13 Aug 2013 04:35:58 +0200

> skb->sk socket can be of AF_INET or AF_INET6 address family. Thus we
> always have to make sure we a referring to the correct interpretation
> of skb->sk.
> 
> We only depend on header defines to query the mtu, so we don't introduce
> a new dependency to ipv6 by this change.
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

This also looks fine to me, Steffen please review and pick it up.
