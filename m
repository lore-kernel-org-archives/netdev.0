From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: netem: do not call qdisc_drop()
 with a NULL skb
Date: Wed, 29 Jun 2016 08:04:21 -0400 (EDT)
Message-ID: <20160629.080421.1061742188520549581.davem@davemloft.net>
References: <1467102608.6850.196.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674AbcF2MEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 08:04:47 -0400
In-Reply-To: <1467102608.6850.196.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 28 Jun 2016 10:30:08 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> If skb_unshare() fails, we call qdisc_drop() with a NULL skb, which
> is no longer supported.
> 
> Fixes: 520ac30f4551 ("net_sched: drop packets after root qdisc lock is released")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
