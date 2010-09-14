From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] flow: better memory management
Date: Mon, 13 Sep 2010 20:03:26 -0700 (PDT)
Message-ID: <20100913.200326.232747308.davem@davemloft.net>
References: <1284138025.24675.100.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49718
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752177Ab0INDDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 23:03:08 -0400
In-Reply-To: <1284138025.24675.100.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Sep 2010 19:00:25 +0200

> Allocate hash tables for every online cpus, not every possible ones.
> 
> NUMA aware allocations.
> 
> Dont use a full page on arches where PAGE_SIZE > 1024*sizeof(void *)
> 
> misc:
>   __percpu , __read_mostly, __cpuinit annotations
>   flow_compare_t is just an "unsigned long"
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.

> +			return notifier_from_errno(res);	

Trailing whitespace, tsk tsk :-)
