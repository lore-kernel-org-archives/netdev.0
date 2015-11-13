From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/14] net: tcp_memcontrol: remove dead per-memcg count
 of allocated sockets
Date: Fri, 13 Nov 2015 11:01:37 -0500 (EST)
Message-ID: <20151113.110137.1839985112517581850.davem@davemloft.net>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
	<1447371693-25143-7-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org,
 mhocko@suse.cz, netdev@vger.kernel.org, linux-mm@kvack.org,
 cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com
To: hannes@cmpxchg.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1447371693-25143-7-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Thu, 12 Nov 2015 18:41:25 -0500

> The number of allocated sockets is used for calculations in the soft
> limit phase, where packets are accepted but the socket is under memory
> pressure. Since there is no soft limit phase in tcp_memcontrol, and
> memory pressure is only entered when packets are already dropped, this
> is actually dead code. Remove it.
> 
> As this is the last user of parent_cg_proto(), remove that too.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
