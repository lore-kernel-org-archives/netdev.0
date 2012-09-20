From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: only run neigh_forced_gc() from one cpu
Date: Wed, 19 Sep 2012 23:51:02 -0400 (EDT)
Message-ID: <20120919.235102.1659819445753338481.davem@davemloft.net>
References: <1348046827.26523.571.camel@edumazet-glaptop>
	<20120919.134503.2070066674881117065.davem@davemloft.net>
	<CAKD1Yr11twYakD=-Mn8FiB11-xtyOLb-Q6XWmiE3H63SFRbzUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, maze@google.com,
	therbert@google.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484Ab2ITDvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 23:51:05 -0400
In-Reply-To: <CAKD1Yr11twYakD=-Mn8FiB11-xtyOLb-Q6XWmiE3H63SFRbzUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Thu, 20 Sep 2012 12:48:09 +0900

> Sorry to butt in, but just to clarify - are you just saying that the
> description should mention IPv6 explicitly, or is there something else
> wrong with the patch?
> 
> If this patch makes IPv6 performance better without affecting IPv4, it's a
> good idea to apply it anyway, right? IPv6 dst entry garbage collection can
> potentially cause serious performance issues on any server with a public
> IPv6 address, and this patch substantially improves the situation.

He's targetting net-next, and I've told him both in previous public
discussions and in recent private communication that the correct fix
is to make ipv6 routes use ref-count-less neighbour handling schemes
like ipv4.

This patch will not be applied as-is, it's not the correct way to fix
this problem.
