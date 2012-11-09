From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 2/9] net: rds: use this_cpu_ptr per-cpu helper
Date: Fri, 9 Nov 2012 20:09:45 +0000
Message-ID: <0000013ae6cadebe-0e44d6a0-5e8c-4ded-a337-d2f41f2ab0e4-000000@email.amazonses.com>
References: <509C687E.1080106@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: venkat.x.venkatsubra@oracle.com,
	David Miller <davem@davemloft.net>, rds-devel@oss.oracle.com,
	NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <509C687E.1080106@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 9 Nov 2012, Shan Wei wrote:

>  net/rds/ib_recv.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
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

if (!__this_cpu_read(cache-0>percpu->first))

?
