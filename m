From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: drop_monitor aware
Date: Wed, 13 Jun 2012 16:00:49 -0700 (PDT)
Message-ID: <20120613.160049.753989290507288197.davem@davemloft.net>
References: <1339601407.22704.380.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648Ab2FMXAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 19:00:50 -0400
In-Reply-To: <1339601407.22704.380.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 Jun 2012 17:30:07 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> When packets are dropped in TX path, its better to use kfree_skb()
> instead of dev_kfree_skb() to give proper drop_monitor events.
> 
> Also move the kfree_skb() call after read_unlock() in bond_alb_xmit()
> and bond_xmit_activebackup()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
