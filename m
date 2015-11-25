From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/13] mm: memcontrol: account socket memory in unified
 hierarchy memory controller
Date: Wed, 25 Nov 2015 11:30:35 -0500 (EST)
Message-ID: <20151125.113035.637118798972617751.davem@davemloft.net>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
	<20151124215844.GA1373@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, vdavydov@virtuozzo.com, mhocko@suse.cz,
 tj@kernel.org, eric.dumazet@gmail.com, netdev@vger.kernel.org,
 linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
 kernel-team@fb.com
To: hannes@cmpxchg.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20151124215844.GA1373@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Tue, 24 Nov 2015 16:58:44 -0500

> Socket memory can be a significant share of overall memory consumed by
> common workloads. In order to provide reasonable resource isolation in
> the unified hierarchy, this type of memory needs to be included in the
> tracking/accounting of a cgroup under active memory resource control.
> 
> Overhead is only incurred when a non-root control group is created AND
> the memory controller is instructed to track and account the memory
> footprint of that group. cgroup.memory=nosocket can be specified on
> the boot commandline to override any runtime configuration and
> forcibly exclude socket memory from active memory resource control.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
