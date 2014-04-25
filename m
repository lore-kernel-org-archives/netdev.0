From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] ipv6_fib limit spinlock hold times for
 /proc/net/ipv6_route
Date: Fri, 25 Apr 2014 15:53:52 -0400 (EDT)
Message-ID: <20140425.155352.128360864032970959.davem@davemloft.net>
References: <535918BC.5030708@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: clm@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46196 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754136AbaDYTxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 15:53:54 -0400
In-Reply-To: <535918BC.5030708@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Mason <clm@fb.com>
Date: Thu, 24 Apr 2014 09:59:24 -0400

> java cats this proc file on startup to search for local routes, and the
> resulting contention on the table lock makes our boxes fall over.

I know it's tangental, but Java should open a netlink socket and probe
for such things properly.
