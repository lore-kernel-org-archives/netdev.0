From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] mm: memcontrol: consolidate cgroup socket tracking
Date: Wed, 14 Sep 2016 16:45:53 -0400
Message-ID: <20160914204553.GC6832@htj.duckdns.org>
References: <20160914194846.11153-1-hannes@cmpxchg.org>
 <20160914194846.11153-3-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Hocko <mhocko@suse.cz>,
	Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Johannes Weiner <hannes@cmpxchg.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20160914194846.11153-3-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 03:48:46PM -0400, Johannes Weiner wrote:
> The cgroup core and the memory controller need to track socket
> ownership for different purposes, but the tracking sites being
> entirely different is kind of ugly.
> 
> Be a better citizen and rename the memory controller callbacks to
> match the cgroup core callbacks, then move them to the same place.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

For 1-3,

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
