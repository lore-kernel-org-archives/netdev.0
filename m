From: David Miller <davem@davemloft.net>
Subject: Re: [RFC davem] revert: net: Make skb->skb_iif always track
 skb->dev
Date: Sat, 12 Jan 2013 13:23:16 -0800 (PST)
Message-ID: <20130112.132316.2121287993605534669.davem@davemloft.net>
References: <50F1699E.1000200@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60584 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754495Ab3ALVXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 16:23:20 -0500
In-Reply-To: <50F1699E.1000200@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Sat, 12 Jan 2013 14:48:14 +0100

> To me it is not clear why skb_iff is needed anyway as the value should
> always be available via skb->dev->ifindex, right?

But all the code uses skb_iif, in particular the ipv4 routing
lookups use that as the key.

It absolutely must follow whatever is skb->dev, it is a hard
invariant.

I am not reverting this change.
