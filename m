From: David Miller <davem@davemloft.net>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 16:47:32 -0400 (EDT)
Message-ID: <20110517.164732.2145088965289526395.davem@davemloft.net>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	<1305663288.2691.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756566Ab1EQUrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 16:47:41 -0400
In-Reply-To: <1305663288.2691.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 May 2011 22:14:48 +0200

> OK but do we have workloads actually needing this optimization at all ?

Yes, I've seen performance graphs where RPS/RFS falls off the cliff
when datagram sizes go from 1024 to 2048 bytes.

Wrt. defrag queue overhead, it still is minor compared to the cost of
processing 1/2 of all packets on one cpu on a 24 core system.

BTW, if we can steer reliably, we could make per-cpu defrag queue if
you worry about it so much :-)
