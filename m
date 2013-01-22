From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next (v2, reword)] neigh: Keep neighbour cache
 entries if number of them is small enough.
Date: Tue, 22 Jan 2013 14:25:57 -0500 (EST)
Message-ID: <20130122.142557.1334303173778603774.davem@davemloft.net>
References: <50FEAE25.4040008@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754419Ab3AVTZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 14:25:59 -0500
In-Reply-To: <50FEAE25.4040008@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Wed, 23 Jan 2013 00:20:05 +0900

> Since we have removed NCE (Neighbour Cache Entry) reference from
> routing entries, the only refcnt holders of an NCE are its timer
> (if running) and its owner table, in usual cases.  As a result,
> neigh_periodic_work() purges NCEs over and over again even for
> gateways.
> 
> It does not make sense to purge entries, if number of them is
> very small, so keep them.  The minimum number of entries to keep
> is specified by gc_thresh1.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks.
