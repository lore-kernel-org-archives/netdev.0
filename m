From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: some RCU conversions
Date: Mon, 01 Aug 2011 01:55:35 -0700 (PDT)
Message-ID: <20110801.015535.2122117382126850912.davem@davemloft.net>
References: <1311837183.2697.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39668 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511Ab1HAIzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 04:55:37 -0400
In-Reply-To: <1311837183.2697.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 Jul 2011 09:13:03 +0200

> ICMP and ND are not fast path, but still we can avoid changing idev
> refcount, using RCU.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Queued up for net-next
