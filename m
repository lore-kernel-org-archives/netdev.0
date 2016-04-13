From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] qlge: Replace create_singlethread_workqueue with
 alloc_ordered_workqueue
Date: Wed, 13 Apr 2016 13:44:22 -0400
Message-ID: <20160413174422.GB3676@htj.duckdns.org>
References: <20160409115744.GA30104@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: harish.patil@qlogic.com, sudarsana.kalluru@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160409115744.GA30104@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 09, 2016 at 05:27:45PM +0530, Amitoj Kaur Chawla wrote:
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

Ping?

-- 
tejun
