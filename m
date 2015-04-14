From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH linux-next v2] mlx5: wrong page mask if
 CONFIG_ARCH_DMA_ADDR_T_64BIT enabled for 32Bit architectures
Date: Tue, 14 Apr 2015 22:23:16 +0300
Message-ID: <20150414192316.GB27750@mtldesk30>
References: <1428916918-24404-1-git-send-email-honli@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1428916918-24404-1-git-send-email-honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 13, 2015 at 05:21:58PM +0800, Honggang Li wrote:
> @@ -241,7 +243,7 @@ static void free_4k(struct mlx5_core_dev *dev, u64 addr)
>  static int alloc_system_page(struct mlx5_core_dev *dev, u16 func_id)
>  {
>  	struct page *page;
> -	u64 addr;
> +	u64 addr = 0;
>  	int err;
>  	int nid = dev_to_node(&dev->pdev->dev);
>  

I really don't see any reason why you need to set addr to 0. Can you
please explain this?
Other than that the patch is ok.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
