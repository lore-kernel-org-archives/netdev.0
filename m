From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pkt_sched: fq: prefetch() fix
Date: Fri, 30 Aug 2013 14:52:40 -0400 (EDT)
Message-ID: <20130830.145240.748677832233085982.davem@davemloft.net>
References: <1377881203.7360.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55939 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753131Ab3H3Sw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:52:56 -0400
In-Reply-To: <1377881203.7360.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 30 Aug 2013 09:46:43 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> kbuild bot reported following m68k build error :
> 
>   net/sched/sch_fq.c: In function 'fq_dequeue':
>>> net/sched/sch_fq.c:491:2: error: implicit declaration of function
> 'prefetch' [-Werror=implicit-function-declaration]
>    cc1: some warnings being treated as errors
> 
> 
> While we are fixing this, move this prefetch() call a bit earlier.
> 
> Reported-by: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
