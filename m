From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: in case of link failure remove route
 directly instead of letting it expire
Date: Wed, 10 Jul 2013 19:46:48 -0700 (PDT)
Message-ID: <20130710.194648.1630059073991776942.davem@davemloft.net>
References: <20130710210057.GL15411@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com,
	yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755354Ab3GKCqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 22:46:52 -0400
In-Reply-To: <20130710210057.GL15411@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 10 Jul 2013 23:00:57 +0200

> We could end up expiring a route which is part of an ecmp route set. Doing
> so would invalidate the rt->rt6i_nsiblings calculations and could provoke
> the following panic:
 ...
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks Hannes.
