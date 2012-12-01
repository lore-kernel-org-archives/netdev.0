From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: change default tcp hash size
Date: Sat, 01 Dec 2012 11:36:56 -0500 (EST)
Message-ID: <20121201.113656.763210835116576607.davem@davemloft.net>
References: <1354306132.20109.41.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489Ab2LAQg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 11:36:57 -0500
In-Reply-To: <1354306132.20109.41.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 30 Nov 2012 12:08:52 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> As time passed, available memory increased faster than number of
> concurrent tcp sockets. 
> 
> As a result, a machine with 4GB of ram gets a hash table
> with 524288 slots, using 8388608 bytes of memory.
> 
> Lets change that by a 16x factor (one slot for 128 KB of ram)
> 
> Even if a small machine needs a _lot_ of sockets, tcp lookups are now
> very efficient, using one cache line per socket.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Agreed, applied, thanks Eric.
