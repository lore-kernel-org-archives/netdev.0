From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] macvlan: remove one synchronize_rcu() call
Date: Fri, 20 May 2011 00:33:28 -0400 (EDT)
Message-ID: <20110520.003328.540815311526933498.davem@davemloft.net>
References: <1305843856.3156.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, greearb@candelatech.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42834 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab1ETEej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 00:34:39 -0400
In-Reply-To: <1305843856.3156.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 May 2011 00:24:16 +0200

> When one macvlan device is dismantled, we can avoid one
> synchronize_rcu() call done after deletion from hash list, since caller
> will perform a synchronize_net() call after its ndo_stop() call.
> 
> Add a new netdev->dismantle field to signal this dismantle intent.
> 
> Reduces RTNL hold time.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
