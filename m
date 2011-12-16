From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10 net-next] Introduce per interface ipv4 statistics
Date: Fri, 16 Dec 2011 13:27:46 -0500 (EST)
Message-ID: <20111216.132746.627284368195962110.davem@davemloft.net>
References: <igorm@etf.rs>
	<1324049163-11207-1-git-send-email-igorm@etf.rs>
	<1324050080.25554.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: igorm@etf.rs, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56826 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760388Ab1LPS1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:27:54 -0500
In-Reply-To: <1324050080.25554.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Dec 2011 16:41:20 +0100

> 1) Why is it needed ? Any RFC requires this bloat ?

I'm not allowing something like this into ipv4, there are too many
terrible side effects in ipv6 because we do it there.

The mere necessity of having to have some device handle at every single packet
processing spot is incredibly painful, and makes changes in the ipv6 packet
paths 10 times more difficult than they otherwise would be.

I'm not allowing this difficulty to be added to the ipv4 side as well.
