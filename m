From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: per cpu uncached list
Date: Thu, 15 Jan 2015 18:26:39 -0500 (EST)
Message-ID: <20150115.182639.1035013313619765901.davem@davemloft.net>
References: <1421277426.11734.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743AbbAOX0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 18:26:41 -0500
In-Reply-To: <1421277426.11734.36.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 Jan 2015 15:17:06 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> RAW sockets with hdrinc suffer from contention on rt_uncached_lock
> spinlock.
> 
> One solution is to use percpu lists, since most routes are destroyed
> by the cpu that created them.
> 
> It is unclear why we even have to put these routes in uncached_list,
> as all outgoing packets should be freed when a device is dismantled.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: caacf05e5ad1 ("ipv4: Properly purge netdev references on uncached routes.")

This looks fine, applied, thanks Eric.
