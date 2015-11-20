From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 07/14] net: tcp_memcontrol: simplify the per-memcg limit
 access
Date: Fri, 20 Nov 2015 12:51:06 +0300
Message-ID: <20151120095106.GZ31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-8-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>,
	<netdev@vger.kernel.org>, <linux-mm@kvack.org>,
	<cgroups@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Johannes Weiner <hannes@cmpxchg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1447371693-25143-8-git-send-email-hannes@cmpxchg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 12, 2015 at 06:41:26PM -0500, Johannes Weiner wrote:
> tcp_memcontrol replicates the global sysctl_mem limit array per
> cgroup, but it only ever sets these entries to the value of the
> memory_allocated page_counter limit. Use the latter directly.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
