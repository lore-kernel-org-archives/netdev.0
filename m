From: David Miller <davem@davemloft.net>
Subject: Re: (3.1.0-rc2-git7) include/linux/inetdevice.h:209 invoked
 rcu_dereference_check() without protection!
Date: Wed, 24 Aug 2011 17:55:36 -0700 (PDT)
Message-ID: <20110824.175536.2182027080149098383.davem@davemloft.net>
References: <20110823024423.GA23874@redhat.com>
	<1314077562.4791.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46020 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678Ab1HYAzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 20:55:42 -0400
In-Reply-To: <1314077562.4791.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 Aug 2011 07:32:42 +0200

> [PATCH] arp: fix rcu lockdep splat in arp_process()
> 
> Dave Jones reported a lockdep splat triggered by an arp_process() call
> from parp_redo().
> 
> Commit faa9dcf793be (arp: RCU changes) is the origin of the bug, since
> it assumed arp_process() was called under rcu_read_lock(), which is not
> true in this particular path.
> 
> Instead of adding rcu_read_lock() in parp_redo(), I chose to add it in 
> neigh_proxy_process() to take care of IPv6 side too.
...
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks!
