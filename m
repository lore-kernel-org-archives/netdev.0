From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: Replace create_singlethread_workqueue with
 alloc_ordered_workqueue
Date: Fri, 15 Apr 2016 16:42:30 -0400 (EDT)
Message-ID: <20160415.164230.2258973922688491525.davem@davemloft.net>
References: <20160409115744.GA30104@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harish.patil@qlogic.com, sudarsana.kalluru@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, tj@kernel.org
To: amitoj1606@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160409115744.GA30104@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Sat, 9 Apr 2016 17:27:45 +0530

> Replace deprecated create_singlethread_workqueue with
> alloc_ordered_workqueue.
> 
> Work items include getting tx/rx frame sizes, resetting MPI processor,
> setting asic recovery bit so ordering seems necessary as only one work
> item should be in queue/executing at any given time, hence the use of
> alloc_ordered_workqueue.
> 
> WQ_MEM_RECLAIM flag has been set since ethernet devices seem to sit in
> memory reclaim path, so to guarantee forward progress regardless of 
> memory pressure.
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
> Acked-by: Tejun Heo <tj@kernel.org>

I'll apply this to net-next, thanks.
