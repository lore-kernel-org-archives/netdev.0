From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 2/9] net: rds: use this_cpu_ptr per-cpu helper
Date: Mon, 12 Nov 2012 23:31:13 +0000
Message-ID: <0000013af6f6652c-8e110b17-56dc-4119-899a-02a627c5485a-000000@email.amazonses.com>
References: <509C687E.1080106@gmail.com> <0000013ae6cadebe-0e44d6a0-5e8c-4ded-a337-d2f41f2ab0e4-000000@email.amazonses.com> <50A0EFE7.9010100@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: venkat.x.venkatsubra@oracle.com,
	David Miller <davem@davemloft.net>, rds-devel@oss.oracle.com,
	NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50A0EFE7.9010100@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Nov 2012, Shan Wei wrote:

> __percpu annotations in struct rds_ib_refill_cache is missing.
>
> you mean that read/write fields of struct rds_ib_cache_head
> using __this_cpu_* operation like following?
> How about it?
>
> diff --git a/net/rds/ib.h b/net/rds/ib.h
> index 8d2b3d5..7280ab8 100644
> --- a/net/rds/ib.h
> +++ b/net/rds/ib.h
> @@ -50,7 +50,7 @@ struct rds_ib_cache_head {
>  };
>
>  struct rds_ib_refill_cache {
> -	struct rds_ib_cache_head *percpu;
> +	struct rds_ib_cache_head __percpu *percpu;

That looks ok.
