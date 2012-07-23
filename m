From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/16] ipv4: Cache input routes in fib_info nexthops.
Date: Mon, 23 Jul 2012 14:06:57 -0700 (PDT)
Message-ID: <20120723.140657.730477254993765697.davem@davemloft.net>
References: <alpine.LFD.2.00.1207231157590.1626@ja.ssi.bg>
	<alpine.LFD.2.00.1207232245230.1619@ja.ssi.bg>
	<20120723.125837.2165279339112720363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663Ab2GWVG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 17:06:58 -0400
In-Reply-To: <20120723.125837.2165279339112720363.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 23 Jul 2012 12:58:37 -0700 (PDT)

> The only time skb->dev->ifindex can change from rt->rt_iif is when we
> demux a tunnel, but at that point we would first reinject and do
> another route lookup, at which point rt->rt_iif would match again.
> 
> And this is the intended semantic of this field anyways.

Ok Julian, you probably already say the DIRECTSRC patches and upcoming
are two patches to take care of the rt->rt_iif thing.
