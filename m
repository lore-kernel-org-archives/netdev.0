From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh: Netlink notification for administrative NUD
 state change
Date: Tue, 17 Dec 2013 16:15:01 -0500 (EST)
Message-ID: <20131217.161501.873058724657031823.davem@davemloft.net>
References: <52ae21ac.oFg7QoGcVg2CCThY%gilligan@aristanetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: gilligan@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240Ab3LQVPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:15:02 -0500
In-Reply-To: <52ae21ac.oFg7QoGcVg2CCThY%gilligan@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bob Gilligan <gilligan@aristanetworks.com>
Date: Sun, 15 Dec 2013 13:39:56 -0800

> 
> The neighbour code sends up an RTM_NEWNEIGH netlink notification if
> the NUD state of a neighbour cache entry is changed by a timer (e.g.
> from REACHABLE to STALE), even if the lladdr of the entry has not
> changed.
> 
> But an administrative change to the the NUD state of a neighbour cache
> entry that does not change the lladdr (e.g. via "ip -4 neigh change
> ...  nud ...") does not trigger a netlink notification.  This means
> that netlink listeners will not hear about administrative NUD state
> changes such as from a resolved state to PERMANENT.
> 
> This patch changes the neighbor code to generate an RTM_NEWNEIGH
> message when the NUD state of an entry is changed administratively.
> 
> Signed-off-by: Bob Gilligan <gilligan@aristanetworks.com>

Applied, thanks Bob.
