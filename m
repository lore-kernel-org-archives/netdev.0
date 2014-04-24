From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fib: fix fib dump restart
Date: Thu, 24 Apr 2014 17:20:07 -0400 (EDT)
Message-ID: <20140424.172007.745724277160255403.davem@davemloft.net>
References: <53591645.7010609@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: clm@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753593AbaDXVUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 17:20:09 -0400
In-Reply-To: <53591645.7010609@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Mason <clm@fb.com>
Date: Thu, 24 Apr 2014 09:48:53 -0400

> 
> From: Kumar Sundararajan <kumar@fb.com>
> 
> When the ipv6 fib changes during a table dump, the walk is
> restarted and the number of nodes dumped are skipped. But the existing
> code doesn't advance to the next node after a node is skipped. This can
> cause the dump to loop or produce lots of duplicates when the fib
> is modified during the dump.
> 
> This change advances the walk to the next node if the current node is
> skipped after a restart.
> 
> Signed-off-by: Chris Mason <clm@fb.com>

Applied and queue up for -stable, thanks.
