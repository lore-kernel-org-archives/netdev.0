From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 11/14] mm: memcontrol: do not account memory+swap on
 unified hierarchy
Date: Sat, 14 Nov 2015 16:23:25 +0300
Message-ID: <20151114132325.GJ31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-12-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, Andrew Morton
	<akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko
	<mhocko@suse.cz>, <netdev@vger.kernel.org>, <linux-mm@kvack.org>,
	<cgroups@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Johannes Weiner <hannes@cmpxchg.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1447371693-25143-12-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 12, 2015 at 06:41:30PM -0500, Johannes Weiner wrote:
> The unified hierarchy memory controller doesn't expose the memory+swap
> counter to userspace, but its accounting is hardcoded in all charge
> paths right now, including the per-cpu charge cache ("the stock").
> 
> To avoid adding yet more pointless memory+swap accounting with the
> socket memory support in unified hierarchy, disable the counter
> altogether when in unified hierarchy mode.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
