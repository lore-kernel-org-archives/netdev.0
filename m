From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix route lookup in addrconf_prefix_rcv()
Date: Sun, 30 Oct 2011 04:13:17 -0400 (EDT)
Message-ID: <20111030.041317.762958848567532756.davem@davemloft.net>
References: <1319635469-19016-1-git-send-email-andi@collax.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@collax.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862Ab1J3INh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2011 04:13:37 -0400
In-Reply-To: <1319635469-19016-1-git-send-email-andi@collax.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Hofmeister <andi@collax.com>
Date: Wed, 26 Oct 2011 15:24:29 +0200

> The route lookup to find a previously auto-configured route for a prefixes used
> to use rt6_lookup(), with the prefix from the RA used as an address. However,
> that kind of lookup ignores routing tables, the prefix length and route flags,
> so when there were other matching routes, even in different tables and/or with
> a different prefix length, the wrong route would be manipulated.
> 
> Now, a new function "addrconf_get_prefix_route()" is used for the route lookup,
> which searches in RT6_TABLE_PREFIX and takes the prefix-length and route flags
> into account.
> 
> Signed-off-by: Andreas Hofmeister <andi@collax.com>

Applied, thanks a lot.
