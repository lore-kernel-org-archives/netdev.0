From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dst: call cond_resched() in dst_gc_task()
Date: Mon, 08 Feb 2010 15:01:26 -0800 (PST)
Message-ID: <20100208.150126.25065601.davem@davemloft.net>
References: <4B701CA8.7050205@itcare.pl>
	<1265639549.3048.33.camel@edumazet-laptop>
	<1265657560.4236.80.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pstaszewski@itcare.pl, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47449
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752799Ab0BHXBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 18:01:12 -0500
In-Reply-To: <1265657560.4236.80.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 08 Feb 2010 20:32:40 +0100

> [PATCH] dst: call cond_resched() in dst_gc_task()
> 
> On some workloads, it is quite possible to get a huge dst list to
> process in dst_gc_task(), and trigger soft lockup detection.
> 
> Fix is to call cond_resched(), as we run in process context.
> 
> Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
> Tested-by: Pawel Staszewski <pstaszewski@itcare.pl>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up to -stable.

When fixing bugs with kernel bugzilla entries, please
mention them in the commit message.  I fixed this up for
you but please take care of it next time.

Thanks!
