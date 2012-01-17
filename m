From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ipv6: dst_allfrag() not taken into account by TCP
Date: Tue, 17 Jan 2012 12:34:05 -0500 (EST)
Message-ID: <20120117.123405.2126678655326303069.davem@davemloft.net>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tore@fud.no
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930Ab2AQRfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 12:35:12 -0500
In-Reply-To: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Jan 2012 17:28:19 +0100

> It seems that dst_allfrag() will force us to use ip6_fragment() and
> reduce effective MSS to :

Don't use TCP with forced fragmentation.

Use path MTU discovery or an artificially reduced route MTU on paths
where ICMP blocking is causing problems.
