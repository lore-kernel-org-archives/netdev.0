From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/9] net: rds: use this_cpu_ptr per-cpu helper
Date: Wed, 31 Oct 2012 17:32:20 +0000
Message-ID: <0000013ab7e18181-c7fd1c9b-5ba6-4765-817f-cbf12448be41-000000@email.amazonses.com>
References: <509109ED.7060900@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: venkat.x.venkatsubra@oracle.com,
	David Miller <davem@davemloft.net>, rds-devel@oss.oracle.com,
	NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <509109ED.7060900@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Oct 2012, Shan Wei wrote:

> diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
> index 8d19491..a4a5064 100644
> --- a/net/rds/ib_recv.c
> +++ b/net/rds/ib_recv.c
> @@ -423,7 +423,7 @@ static void rds_ib_recv_cache_put(struct list_head *new_item,
>
>  	local_irq_save(flags);
>
> -	chp = per_cpu_ptr(cache->percpu, smp_processor_id());
> +	chp = this_cpu_ptr(cache->percpu);
>  	if (!chp->first)
>  		INIT_LIST_HEAD(new_item);
>  	else /* put on front */
>

Reviewed-by: Christoph Lameter <cl@linux.com>
