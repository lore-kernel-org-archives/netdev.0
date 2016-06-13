From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net_sched: prio: properly report out of memory
 errors
Date: Sun, 12 Jun 2016 21:57:13 -0400 (EDT)
Message-ID: <20160612.215713.300275598579322779.davem@davemloft.net>
References: <1465773707.7945.133.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54421 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933059AbcFMB5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 21:57:17 -0400
In-Reply-To: <1465773707.7945.133.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 12 Jun 2016 16:21:47 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> At Qdisc creation or change time, prio_tune() creates missing
> pfifo qdiscs but does not return an error code if one
> qdisc could not be allocated.
> 
> Leaving a qdisc in non operational state without telling user
> anything about this problem is not good.
> 
> Also, testing if we replace something different than noop_qdisc
> a second time makes no sense so I removed useless code.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
