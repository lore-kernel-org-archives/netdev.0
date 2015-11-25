From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/13] mm: memcontrol: do not account memory+swap on
 unified hierarchy
Date: Wed, 25 Nov 2015 11:29:21 -0500 (EST)
Message-ID: <20151125.112921.1371682675467323296.davem@davemloft.net>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
	<1448401925-22501-11-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.cz,
 tj@kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org,
 linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
 kernel-team@fb.com
To: hannes@cmpxchg.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1448401925-22501-11-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 24 Nov 2015 16:52:02 -0500

> The unified hierarchy memory controller doesn't expose the memory+swap
> counter to userspace, but its accounting is hardcoded in all charge
> paths right now, including the per-cpu charge cache ("the stock").
> 
> To avoid adding yet more pointless memory+swap accounting with the
> socket memory support in unified hierarchy, disable the counter
> altogether when in unified hierarchy mode.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
