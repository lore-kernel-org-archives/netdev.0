From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib_rules: reorder struct fib_rules fields
Date: Sat, 03 Aug 2013 11:54:08 -0700 (PDT)
Message-ID: <20130803.115408.389552762427955941.davem@davemloft.net>
References: <1375555835.4457.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefan.tomanek@wertarbyte.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640Ab3HCSyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 14:54:09 -0400
In-Reply-To: <1375555835.4457.26.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 03 Aug 2013 11:50:35 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Move refcnt, pref, suppress_ifgroup, suppress_prefixlen out of first
> cache line, as they are not used in fast path.
> 
> Make sure ctarget & fr_net are in first cache line.
> 
> (Assuming 64 bit arches and 64 bytes cache lines)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
