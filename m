From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] net/mlx5_core/pagealloc: Remove deprecated
 create_singlethread_workqueue
Date: Fri, 29 Jul 2016 08:22:37 -0400
Message-ID: <20160729122237.GG2542@mtj.duckdns.org>
References: <20160728081949.GA5561@Karyakshetra>
 <20160728093735.GO4628@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160728093735.GO4628-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, Jul 28, 2016 at 12:37:35PM +0300, Leon Romanovsky wrote:
> Did you test this patch? Did you notice the memory reclaim path nature
> of this work?

The conversion uses WQ_MEM_RECLAIM, which is standard for all
workqueues which can stall packet processing if stalled.  The
requirement comes from nfs or block devices over network.

Thanks.

-- 
tejun
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
