From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Remove deprecated
 create_singlethread_workqueue
Date: Thu, 01 Sep 2016 16:41:41 -0700 (PDT)
Message-ID: <20160901.164141.1919969808031777069.davem@davemloft.net>
References: <20160830163201.GA25869@Karyakshetra>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
        tj@kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhaktipriya96@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160830163201.GA25869@Karyakshetra>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Date: Tue, 30 Aug 2016 22:02:01 +0530

> alloc_ordered_workqueue() with WQ_MEM_RECLAIM set, replaces
> deprecated create_singlethread_workqueue(). This is the identity
> conversion.
> 
> The workqueue "wq" queues multiple work items viz
> &bond->mcast_work, &nnw->work, &bond->mii_work, &bond->arp_work,
> &bond->alb_work, &bond->mii_work, &bond->ad_work, &bond->slave_arr_work
> which require strict execution ordering. Hence, an ordered dedicated
> workqueue has been used.
> 
> Since, it is a network driver, WQ_MEM_RECLAIM has been set to
> ensure forward progress under memory pressure.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

Applied.
