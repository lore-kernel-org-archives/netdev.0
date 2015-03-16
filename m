From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp_metrics: fix wrong lockdep annotations
Date: Mon, 16 Mar 2015 16:32:38 -0400 (EDT)
Message-ID: <20150316.163238.212681875092833561.davem@davemloft.net>
References: <20150316113542.GA27127@paralelels.com>
	<1426514329.11398.204.camel@edumazet-glaptop2.roam.corp.google.com>
	<1426515274.11398.209.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avagin@parallels.com, ebiederm@xmission.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37721 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753807AbbCPUck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 16:32:40 -0400
In-Reply-To: <1426515274.11398.209.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 16 Mar 2015 07:14:34 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Changes in tcp_metric hash table are protected by tcp_metrics_lock
> only, not by genl_mutex
> 
> While we are at it use deref_locked() instead of rcu_dereference()
> in tcp_new() to avoid unnecessary barrier, as we hold tcp_metrics_lock
> as well.
>  
> Reported-by: Andrew Vagin <avagin@parallels.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 098a697b497e ("tcp_metrics: Use a single hash table for all network namespaces.")

Applied, thanks Eric.
