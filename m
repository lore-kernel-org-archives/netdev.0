From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2] cfg80211: Remove deprecated
 create_singlethread_workqueue
Date: Wed, 31 Aug 2016 10:26:02 -0400
Message-ID: <20160831142602.GO12660@htj.duckdns.org>
References: <20160830190507.GA11493@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160830190507.GA11493@Karyakshetra>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 31, 2016 at 12:35:07AM +0530, Bhaktipriya Shridhar wrote:
> The workqueue "cfg80211_wq" is involved in cleanup, scan and event related
> works. It queues multiple work items &rdev->event_work,
> &rdev->dfs_update_channels_wk,
> &wiphy_to_rdev(request->wiphy)->scan_done_wk,
> &wiphy_to_rdev(wiphy)->sched_scan_results_wk, which require strict
> execution ordering.
> Hence, an ordered dedicated workqueue has been used.
> 
> Since it's a wireless driver, WQ_MEM_RECLAIM has been set to ensure
> forward progress under memory pressure.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Acked-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Thanks.

-- 
tejun
