From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: fix a dst leak in tunnels
Date: Fri, 17 Jan 2014 18:37:49 -0800 (PST)
Message-ID: <20140117.183749.2104270426477704867.davem@davemloft.net>
References: <1389919279.31367.439.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, maze@google.com,
	cwang@twopensource.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbaARChu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 21:37:50 -0500
In-Reply-To: <1389919279.31367.439.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Jan 2014 16:41:19 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> This patch :
> 
> 1) Remove a dst leak if DST_NOCACHE was set on dst
>    Fix this by holding a reference only if dst really cached.
> 
> 2) Remove a lockdep warning in __tunnel_dst_set()
>     This was reported by Cong Wang.
> 
> 3) Remove usage of a spinlock where xchg() is enough
> 
> 4) Remove some spurious inline keywords.
>    Let compiler decide for us.
> 
> Fixes: 7d442fab0a67 ("ipv4: Cache dst in tunnels")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
