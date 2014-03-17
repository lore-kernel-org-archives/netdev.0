From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netfilter: conntrack: Fix UP builds
Date: Mon, 17 Mar 2014 17:15:07 -0400 (EDT)
Message-ID: <20140317.171507.1078092240612029454.davem@davemloft.net>
References: <1395088673.9668.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, pablo@netfilter.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbaCQVPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 17:15:11 -0400
In-Reply-To: <1395088673.9668.65.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 17 Mar 2014 13:37:53 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> ARRAY_SIZE(nf_conntrack_locks) is undefined if spinlock_t is an
> empty structure. Replace it by CONNTRACK_LOCKS
> 
> Fixes: 93bb0ceb75be ("netfilter: conntrack: remove central spinlock nf_conntrack_lock")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
> David, you might merge this asap instead of going through Pablo queue ?

Sure, applied, thanks Eric.
