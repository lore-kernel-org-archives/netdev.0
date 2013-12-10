From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: fix NULL pointer Oops in fib(6)_rule_suppress
Date: Tue, 10 Dec 2013 17:56:11 -0500 (EST)
Message-ID: <20131210.175611.817301757454300416.davem@davemloft.net>
References: <20131210222124.GG3260@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel.golle@gmail.com,
	sergei.shtylyov@cogentembedded.com, eric.dumazet@gmail.com
To: stefan.tomanek@wertarbyte.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab3LJW4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 17:56:13 -0500
In-Reply-To: <20131210222124.GG3260@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Date: Tue, 10 Dec 2013 23:21:25 +0100

> This changes ensures that the routing entry investigated by the suppress
> function actually does point to a device struct before following that pointer,
> fixing a possible kernel oops situation when verifying the interface group
> associated with a routing table entry.
> 
> According to Daniel Golle, this Oops can be triggered by a user process trying
> to establish an outgoing IPv6 connection while having no real IPv6 connectivity
> set up (only autoassigned link-local addresses).
> 
> Fixes: 6ef94cfafba15 ("fib_rules: add route suppression based on ifgroup")
> 
> Reported-by: Daniel Golle <daniel.golle@gmail.com>
> Tested-by: Daniel Golle <daniel.golle@gmail.com>
> Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>

Looks good, applied and queued up for -stable, thanks!
