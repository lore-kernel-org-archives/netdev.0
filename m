From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: cavium: liquidio: request_manager:
 Remove create_workqueue
Date: Mon, 06 Jun 2016 21:17:38 -0400 (EDT)
Message-ID: <20160606.211738.2024649171587450962.davem@davemloft.net>
References: <20160604152400.GA559@Karyakshetra>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, tj@kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhaktipriya96@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160604152400.GA559@Karyakshetra>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Date: Sat, 4 Jun 2016 20:54:00 +0530

> alloc_workqueue replaces deprecated create_workqueue().
> 
> A dedicated workqueue has been used since the workitem viz
> (&db_wq->wk.work which maps to check_db_timeout) is involved
> in normal device operation. WQ_MEM_RECLAIM has been set to guarantee
> forward progress under memory pressure, which is a requirement here.
> Since there are only a fixed number of work items, explicit concurrency
> limit is unnecessary.
> 
> flush_workqueue is unnecessary since destroy_workqueue() itself calls
> drain_workqueue() which flushes repeatedly till the workqueue
> becomes empty.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

Applied.
