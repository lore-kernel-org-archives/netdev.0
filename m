From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: remove some sparse warnings
Date: Thu, 05 Feb 2015 00:41:26 -0800 (PST)
Message-ID: <20150205.004126.2028721941100638117.davem@davemloft.net>
References: <1423085864.31870.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752906AbbBEIl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 03:41:27 -0500
In-Reply-To: <1423085864.31870.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Feb 2015 13:37:44 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> netdev_adjacent_add_links() and netdev_adjacent_del_links()
> are static.
> 
> queue->qdisc has __rcu annotation, need to use RCU_INIT_POINTER()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
