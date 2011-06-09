From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: pmtu_expires fixes
Date: Thu, 09 Jun 2011 00:25:27 -0700 (PDT)
Message-ID: <20110609.002527.263847988277639548.davem@davemloft.net>
References: <1307549227.3057.64.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791Ab1FIHZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 03:25:31 -0400
In-Reply-To: <1307549227.3057.64.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Jun 2011 18:07:07 +0200

> commit 2c8cec5c10bc (ipv4: Cache learned PMTU information in inetpeer)
> added some racy peer->pmtu_expires accesses.
> 
> As its value can be changed by another cpu/thread, we should be more
> careful, reading its value once.
> 
> Add peer_pmtu_expired() and peer_pmtu_cleaned() helpers
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I've decided to apply this to net-2.6, thanks Eric.
