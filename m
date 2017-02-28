From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [PATCH 1/1] rds: ib: add the static type to the variables
Date: Tue, 28 Feb 2017 09:20:18 +0200
Message-ID: <20170228072017.GA3678@yuval-lap.uk.oracle.com>
References: <1488264340-20044-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        davem@davemloft.net
To: Zhu Yanjun <yanjun.zhu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:36054 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751835AbdB1IBA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 03:01:00 -0500
Content-Disposition: inline
In-Reply-To: <1488264340-20044-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 28, 2017 at 01:45:40AM -0500, Zhu Yanjun wrote:
> The variables rds_ib_mr_1m_pool_size and rds_ib_mr_8k_pool_size
> are used only in the ib.c file. As such, the static type is
> added to limit them in this file.
> 
> Cc: Joe Jin <joe.jin@oracle.com>
> Cc: Junxiao Bi <junxiao.bi@oracle.com>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
> ---
>  net/rds/ib.c    | 4 ++--
>  net/rds/ib_mr.h | 2 --
>  2 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/net/rds/ib.c b/net/rds/ib.c
> index 8d70884..ecff01b 100644
> --- a/net/rds/ib.c
> +++ b/net/rds/ib.c
> @@ -45,8 +45,8 @@
>  #include "ib.h"
>  #include "ib_mr.h"
>  
> -unsigned int rds_ib_mr_1m_pool_size = RDS_MR_1M_POOL_SIZE;
> -unsigned int rds_ib_mr_8k_pool_size = RDS_MR_8K_POOL_SIZE;
> +static unsigned int rds_ib_mr_1m_pool_size = RDS_MR_1M_POOL_SIZE;
> +static unsigned int rds_ib_mr_8k_pool_size = RDS_MR_8K_POOL_SIZE;
>  unsigned int rds_ib_retry_count = RDS_IB_DEFAULT_RETRY_COUNT;
>  
>  module_param(rds_ib_mr_1m_pool_size, int, 0444);
> diff --git a/net/rds/ib_mr.h b/net/rds/ib_mr.h
> index 24c086d..5d6e98a 100644
> --- a/net/rds/ib_mr.h
> +++ b/net/rds/ib_mr.h
> @@ -107,8 +107,6 @@ struct rds_ib_mr_pool {
>  };
>  
>  extern struct workqueue_struct *rds_ib_mr_wq;
> -extern unsigned int rds_ib_mr_1m_pool_size;
> -extern unsigned int rds_ib_mr_8k_pool_size;
>  extern bool prefer_frmr;

Reviewed-by: Yuval Shaia <yuval.shaia@oracle.com>

>  
>  struct rds_ib_mr_pool *rds_ib_create_mr_pool(struct rds_ib_device *rds_dev,
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
