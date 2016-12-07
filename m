From: David Miller <davem@davemloft.net>
Subject: Re: [net-next][PATCH v2 18/18] RDS: IB: add missing connection
 cache usage info
Date: Wed, 07 Dec 2016 10:55:31 -0500 (EST)
Message-ID: <20161207.105531.1347292514118544125.davem@davemloft.net>
References: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
        <1481083316-11648-19-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481083316-11648-19-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Tue,  6 Dec 2016 20:01:56 -0800

> rds-tools already support it.
> 
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> ---
>  include/uapi/linux/rds.h | 1 +
>  net/rds/ib.c             | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/include/uapi/linux/rds.h b/include/uapi/linux/rds.h
> index 3833113..410ae3c 100644
> --- a/include/uapi/linux/rds.h
> +++ b/include/uapi/linux/rds.h
> @@ -183,6 +183,7 @@ struct rds_info_rdma_connection {
>  	uint32_t	max_send_sge;
>  	uint32_t	rdma_mr_max;
>  	uint32_t	rdma_mr_size;
> +	uint32_t	cache_allocs;
>  };
>  
>  /* RDS message Receive Path Latency points */

What level of compatability exists here?  If we run an old tool on a new
kernel, or a new tool on an old kernel, does it work properly?
