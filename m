From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cavium: liquidio: Remove deprecated
 create_workqueue
Date: Thu, 09 Jun 2016 23:49:07 -0700 (PDT)
Message-ID: <20160609.234907.1896722620762197262.davem@davemloft.net>
References: <20160607201758.GA14937@Karyakshetra>
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
In-Reply-To: <20160607201758.GA14937@Karyakshetra>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Date: Wed, 8 Jun 2016 01:47:59 +0530

> alloc_workqueue replaces deprecated create_workqueue().
> 
> A dedicated workqueue has been used since the workitem viz
> (&lio->txq_status_wq.wk.work which maps to octnet_poll_check_txq_status)
> is involved in a brief poll routine for checking transmit queue status
> and is an intergral part of normal device operation.
> WQ_MEM_RECLAIM has been set to guarantee forward progress under memory
> pressure, which is a requirement here.
> Since there are only a fixed number of work items, explicit concurrency
> limit is unnecessary.
> 
> flush_workqueue is unnecessary since destroy_workqueue() itself calls
> drain_workqueue() which flushes repeatedly till the workqueue
> becomes empty.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

Applied.
