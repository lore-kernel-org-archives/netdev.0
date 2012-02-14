From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: netpoll_poll_dev() should access dev->flags
Date: Tue, 14 Feb 2012 15:25:04 -0500 (EST)
Message-ID: <20120214.152504.555306961508318697.davem@davemloft.net>
References: <1329217821.2336.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120214.144251.1481952602061158777.davem@davemloft.net>
	<1329250319.2555.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org, nhorman@tuxdriver.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755510Ab2BNU0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 15:26:12 -0500
In-Reply-To: <1329250319.2555.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 Feb 2012 21:11:59 +0100

> commit 5a698af53f (bond: service netpoll arp queue on master device)
> tested IFF_SLAVE flag against dev->priv_flags instead of dev->flags 
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: WANG Cong <amwang@redhat.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied and queued up for -stable, thanks Eric.
