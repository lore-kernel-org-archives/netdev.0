From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif-hsi: Remove deprecated
 create_singlethread_workqueue
Date: Mon, 25 Jul 2016 21:39:48 -0700 (PDT)
Message-ID: <20160725.213948.1597000820762206692.davem@davemloft.net>
References: <20160725131057.GA751@Karyakshetra>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.tarnyagin@lockless.no, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tj@kernel.org
To: bhaktipriya96@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160725131057.GA751@Karyakshetra>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Date: Mon, 25 Jul 2016 18:40:57 +0530

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

Applied.
