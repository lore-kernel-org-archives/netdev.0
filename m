From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net/mlx4: suppress 'may be used uninitialized' warning
Date: Thu, 20 Apr 2017 13:19:49 -0400 (EDT)
Message-ID: <20170420.131949.157388310132608724.davem@davemloft.net>
References: <20170418062135.76698-1-gthelen@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org,
        matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, idos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170418062135.76698-1-gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Date: Mon, 17 Apr 2017 23:21:35 -0700

> gcc 4.8.4 complains that mlx4_SW2HW_MPT_wrapper() uses an uninitialized
> 'mpt' variable:
>   drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function 'mlx4_SW2HW_MPT_wrapper':
>   drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:2802:12: warning: 'mpt' may be used uninitialized in this function [-Wmaybe-uninitialized]
>      mpt->mtt = mtt;
> 
> I think this warning is a false complaint.  mpt is only used when
> mr_res_start_move_to() return zero, and in all such cases it initializes
> mpt.  But apparently gcc cannot see that.
> 
> Initialize mpt to avoid the warning.
> 
> Signed-off-by: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Appied to net-next.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
