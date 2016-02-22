From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [net-next][PATCH 11/13] RDS: IB: add Fastreg MR (FRMR)
 detection support
Date: Sun, 21 Feb 2016 22:36:56 -0500 (EST)
Message-ID: <20160221.223656.2213596964617869651.davem@davemloft.net>
References: <1455967804-27644-1-git-send-email-santosh.shilimkar@oracle.com>
	<1455967804-27644-12-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1455967804-27644-12-git-send-email-santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date: Sat, 20 Feb 2016 03:30:02 -0800

> @@ -54,6 +55,8 @@ module_param(rds_ib_mr_8k_pool_size, int, 0444);
>  MODULE_PARM_DESC(rds_ib_mr_8k_pool_size, " Max number of 8K mr per HCA");
>  module_param(rds_ib_retry_count, int, 0444);
>  MODULE_PARM_DESC(rds_ib_retry_count, " Number of hw retries before reporting an error");
> +module_param(prefer_frmr, bool, 0444);
> +MODULE_PARM_DESC(prefer_frmr, "Preferred MR method if both FMR and FRMR supported");

Sorry, you're going to have to create a real run time method to configure
this parameter.

I'm strongly against module parameters.

Please don't go into details about why this might be difficult to do,
I'm totally not interested.  Doing things properly is sometimes not
easy, that's life.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
