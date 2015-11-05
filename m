From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Date: Thu, 05 Nov 2015 11:30:12 -0500 (EST)
Message-ID: <20151105.113012.433525933573324396.davem@davemloft.net>
References: <20151105144002.GB15111@dhcp22.suse.cz>
	<20151105.111609.1695015438589063316.davem@davemloft.net>
	<20151105162803.GD15111@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, vdavydov@virtuozzo.com,
 tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org,
 cgroups@vger.kernel.org, linux-kernel@vger.kernel.org
To: mhocko@kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20151105162803.GD15111@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 5 Nov 2015 17:28:03 +0100

> Yes, that part is clear and Johannes made it clear that the kmem tcp
> part is disabled by default. Or are you considering also all the slab
> usage by the networking code as well?

I'm still thinking about the implications of that aspect, and will
comment when I have something coherent to say about it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
