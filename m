From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] htb: fix two bugs
Date: Tue, 06 Nov 2012 19:06:55 -0500 (EST)
Message-ID: <20121106.190655.1944399936693318220.davem@davemloft.net>
References: <1352169649.3140.59.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vimal@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32926 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828Ab2KGAG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 19:06:56 -0500
In-Reply-To: <1352169649.3140.59.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 05 Nov 2012 18:40:49 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 56b765b79e9 (htb: improved accuracy at high rates)
> introduced two bugs :
> 
> 1) one bstats_update() was inadvertently removed from
>    htb_dequeue_tree(), breaking statistics/rate estimation.
> 
> 2) Missing qdisc_put_rtab() calls in htb_change_class(),
>    leaking kernel memory, now struct htb_class no longer
>    retains pointers to qdisc_rate_table structs.
> 
>    Since only rate is used, dont use qdisc_get_rtab() calls
>    copying data we ignore anyway.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
