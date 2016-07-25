From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] caif-hsi: Remove deprecated create_singlethread_workqueue
Date: Mon, 25 Jul 2016 14:56:11 -0400
Message-ID: <20160725185611.GH19588@mtj.duckdns.org>
References: <20160725131057.GA751@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160725131057.GA751@Karyakshetra>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 25, 2016 at 06:40:57PM +0530, Bhaktipriya Shridhar wrote:
> alloc_workqueue replaces deprecated create_singlethread_workqueue().
> 
> A dedicated workqueue has been used since the workitems are being used
> on a packet tx/rx path. Hence, WQ_MEM_RECLAIM has been set to guarantee
> forward progress under memory pressure.
> 
> An ordered workqueue has been used since workitems &cfhsi->wake_up_work
> and &cfhsi->wake_down_work cannot be run concurrently.
> 
> Calls to flush_workqueue() before destroy_workqueue() have been dropped
> since destroy_workqueue() itself calls drain_workqueue() which flushes
> repeatedly till the workqueue becomes empty.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
