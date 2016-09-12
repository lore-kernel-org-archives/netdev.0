From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] cfg80211: Remove deprecated
 create_singlethread_workqueue
Date: Mon, 12 Sep 2016 11:21:40 +0200
Message-ID: <1473672100.4201.15.camel@sipsolutions.net>
References: <20160830190507.GA11493@Karyakshetra>
         (sfid-20160830_210511_814586_97B3779A)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160830190507.GA11493@Karyakshetra> (sfid-20160830_210511_814586_97B3779A)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-08-31 at 00:35 +0530, Bhaktipriya Shridhar wrote:
> The workqueue "cfg80211_wq" is involved in cleanup, scan and event
> related
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

Applied, thanks.

johannes
