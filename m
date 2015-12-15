From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net_sched: make qdisc_tree_decrease_qlen() work
 for non mq
Date: Tue, 15 Dec 2015 13:42:33 -0500 (EST)
Message-ID: <20151215.134233.1041810878194617389.davem@davemloft.net>
References: <1450201392.8474.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stasn77@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49132 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753949AbbLOSmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 13:42:35 -0500
In-Reply-To: <1450201392.8474.37.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Dec 2015 09:43:12 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Stas Nichiporovich reported a regression in his HFSC qdisc setup
> on a non multi queue device.
> 
> It turns out I mistakenly added a TCQ_F_NOPARENT flag on all qdisc
> allocated in qdisc_create() for non multi queue devices, which was
> rather buggy. I was clearly mislead by the TCQ_F_ONETXQUEUE that is
> also set here for no good reason, since it only matters for the root
> qdisc.
> 
> Fixes: 4eaf3b84f288 ("net_sched: fix qdisc_tree_decrease_qlen() races")
> Reported-by: Stas Nichiporovich <stasn77@gmail.com>
> Tested-by: Stas Nichiporovich <stasn77@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
