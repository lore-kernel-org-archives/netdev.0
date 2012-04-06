From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: fix races after skb queueing
Date: Fri, 06 Apr 2012 04:21:44 -0400 (EDT)
Message-ID: <20120406.042144.742495137515648292.davem@davemloft.net>
References: <1333700266.5312.19.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752822Ab2DFIVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 04:21:46 -0400
In-Reply-To: <1333700266.5312.19.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Apr 2012 10:17:46 +0200

> As soon as an skb is queued into socket receive_queue, another thread
> can consume it, so we are not allowed to reference skb anymore, or risk
> use after free.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Good catch Eric.

Applied and queued up for -stable.
