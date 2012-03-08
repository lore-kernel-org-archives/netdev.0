From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] inetpeer: Invalidate the inetpeer tree along with
 the routing cache
Date: Thu, 08 Mar 2012 00:31:14 -0800 (PST)
Message-ID: <20120308.003114.354787734514253352.davem@davemloft.net>
References: <20120307071940.GF15404@secunet.com>
	<20120307072026.GG15404@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754742Ab2CHIbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 03:31:32 -0500
In-Reply-To: <20120307072026.GG15404@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 7 Mar 2012 08:20:26 +0100

> We initialize the routing metrics with the values cached on the
> inetpeer in rt_init_metrics(). So if we have the metrics cached on the
> inetpeer, we ignore the user configured fib_metrics.
> 
> To fix this issue, we replace the old tree with a fresh initialized
> inet_peer_base. The old tree is removed later with a delayed work queue.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied, but I had to fixup trailing whitespace:

> +	spin_lock_bh(&gc_lock);	

at the end of that line.
