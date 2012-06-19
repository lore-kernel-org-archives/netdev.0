From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Move ipv6 proc file registration to end of init
 order
Date: Mon, 18 Jun 2012 18:39:16 -0700 (PDT)
Message-ID: <20120618.183916.1295267206223791197.davem@davemloft.net>
References: <1432a6aff6ee203a688e78b06ed8000475385564.1340057223.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49369 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753873Ab2FSBjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 21:39:19 -0400
In-Reply-To: <1432a6aff6ee203a688e78b06ed8000475385564.1340057223.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 19 Jun 2012 00:08:33 +0200

> /proc/net/ipv6_route reflects the contents of fib_table_hash. The proc
> handler is installed in ip6_route_net_init() whereas fib_table_hash is
> allocated in fib6_net_init() _after_ the proc handler has been installed.
> 
> This opens up a short time frame to access fib_table_hash with its pants
> down.
> 
> Move the registration of the proc files to a later point in the init
> order to avoid the race.
> 
> Tested :-)
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

This looks a lot better, applied, thanks Thomas.
