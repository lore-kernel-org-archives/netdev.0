From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] net/mlx5e: Fix possible memory leak
Date: Thu, 18 May 2017 15:19:09 -0400 (EDT)
Message-ID: <20170518.151909.1042064929995125830.davem@davemloft.net>
References: <20170518153441.24398-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        hadarh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, weiyongjun1-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170518153441.24398-1-weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 18 May 2017 15:34:41 +0000

> From: Wei Yongjun <weiyongjun1-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> 
> 'encap_header' is malloced and should be freed before leaving from
> the error handling cases, otherwise it will cause memory leak.
> 
> Fixes: 232c001398ae ("net/mlx5e: Add support to neighbour update flow")
> Signed-off-by: Wei Yongjun <weiyongjun1-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
