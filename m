From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] net: ethernet: cavium: liquidio: request_manager: Remove
 create_workqueue
Date: Sun, 5 Jun 2016 06:26:01 -0400
Message-ID: <20160605102601.GC31708@htj.duckdns.org>
References: <20160604152400.GA559@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160604152400.GA559@Karyakshetra>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 04, 2016 at 08:54:00PM +0530, Bhaktipriya Shridhar wrote:
> diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
> index a2a2465..9313915 100644
> --- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
> +++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
> @@ -144,7 +144,9 @@ int octeon_init_instr_queue(struct octeon_device *oct,
> 
>  	oct->fn_list.setup_iq_regs(oct, iq_no);
> 
> -	oct->check_db_wq[iq_no].wq = create_workqueue("check_iq_db");
> +	oct->check_db_wq[iq_no].wq = alloc_workqueue("check_iq_db",
> +						     WQ_MEM_RECLAIM,
> +						     0);

Why the new line between WQ_MEM_RECLAIM and 0?

Except for the subj tag and the above nit,

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
