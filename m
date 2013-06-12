From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: htb: do not setup default rate
 estimators
Date: Wed, 12 Jun 2013 00:14:41 -0700 (PDT)
Message-ID: <20130612.001441.1628304783101981390.davem@davemloft.net>
References: <1370555596.24311.390.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755600Ab3FLHOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 03:14:43 -0400
In-Reply-To: <1370555596.24311.390.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Jun 2013 14:53:16 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> With a thousand htb classes, est_timer() spends ~5 million cpu cycles
> and throws out cpu cache, because each htb class has a default
> rate estimator (est 4sec 16sec).
> 
> Most users do not use default rate estimators, so switch htb
> to not setup ones.
> 
> Add a module parameter (htb_rate_est) so that users relying
> on this default rate estimator can revert the behavior.
> 
> echo 1 >/sys/module/sch_htb/parameters/htb_rate_est
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Fair enough, applied, let's see if anyone complains.
