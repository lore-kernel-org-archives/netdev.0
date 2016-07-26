From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/mlx5_core/health: Remove deprecated
 create_singlethread_workqueue
Date: Tue, 26 Jul 2016 15:19:21 -0700 (PDT)
Message-ID: <20160726.151921.304567441512097113.davem@davemloft.net>
References: <20160717051327.GA20674@leon.nu>
	<20160726170824.GA10721@Karyakshetra>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matanb@mellanox.com, leonro@mellanox.com, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	tj@kernel.org
To: bhaktipriya96@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160726170824.GA10721@Karyakshetra>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Date: Tue, 26 Jul 2016 22:38:24 +0530

> The workqueue health->wq was used as per device private health thread.
> This was done to perform delayed work.
> 
> The workqueue has a single workitem(&health->work) and
> hence doesn't require ordering. It is involved in handling the health of
> the device and is not being used on a memory reclaim path.
> Hence, the singlethreaded workqueue has been replaced with the use of
> system_wq.
> 
> Work item has been flushed in mlx5_health_cleanup() to ensure that
> there are no pending tasks while disconnecting the driver.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

Applied.
