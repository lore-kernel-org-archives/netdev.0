From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Prevent access to uninitialized fib_table_hash
 via /proc/net/ipv6_route
Date: Sat, 16 Jun 2012 15:22:01 -0700 (PDT)
Message-ID: <20120616.152201.604219757642573995.davem@davemloft.net>
References: <20120615.153240.1699971156820399680.davem@davemloft.net>
	<20120615.221502.1196734470412725503.davem@davemloft.net>
	<20120616130723.GA8388@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58261 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756899Ab2FPWWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jun 2012 18:22:02 -0400
In-Reply-To: <20120616130723.GA8388@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Sat, 16 Jun 2012 09:07:23 -0400

> Perhaps the flag on the proc file like we discussed might be the
> better way to go after all here Thomas.

I suspect Thomas's general approach was fine, he just was trying
to hard. :-)

Just seperate exactly the procfs, sysctl, etc. stuff into a completely
seperate set of network namespace ops, and do it dead last in the
initialization list.

At least that is how I would approach the fix.
