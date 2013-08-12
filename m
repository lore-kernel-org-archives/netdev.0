From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvtap: fix two races
Date: Sun, 11 Aug 2013 21:50:49 -0700 (PDT)
Message-ID: <20130811.215049.2058314780489790321.davem@davemloft.net>
References: <1375968072.4004.92.camel@edumazet-glaptop>
	<20130808155634.239dbc2d@thhw500>
	<1375974374.4004.103.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, netdev@vger.kernel.org,
	vyasevic@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854Ab3HLEp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 00:45:27 -0400
In-Reply-To: <1375974374.4004.103.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Aug 2013 08:06:14 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Since commit ac4e4af1e59e1 ("macvtap: Consistently use rcu functions"),
> Thomas gets two different warnings :
 ...
> And
 ...
> In the first case, macvtap_put_user() calls macvlan_count_rx()
> in a preempt-able context, and this is not allowed.
> 
> In the second case, macvtap_get_user() calls
> macvlan_start_xmit() with BH enabled, and this is not allowed.
>  
> Reported-by: Thomas Huth <thuth@linux.vnet.ibm.com>
> Bisected-by: Thomas Huth <thuth@linux.vnet.ibm.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Thomas Huth <thuth@linux.vnet.ibm.com>
> Cc: Vlad Yasevich <vyasevic@redhat.com>

Applied and queued up for -stable, thanks.
