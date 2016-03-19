From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] net/mlx4_core: Fix backward compatibility on
 VFs
Date: Fri, 18 Mar 2016 23:11:06 -0400 (EDT)
Message-ID: <20160318.231106.2099055485546956238.davem@davemloft.net>
References: <1458233382-12871-1-git-send-email-eli@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, aik-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org
To: eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1458233382-12871-1-git-send-email-eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Thu, 17 Mar 2016 18:49:42 +0200

> Commit 85743f1eb345 ("net/mlx4_core: Set UAR page size to 4KB regardless
> of system page size") introduced dependency where old VF drivers without
> this fix fail to load if the PF driver runs with this commit.
> 
> To resolve this add a module parameter which disables that functionality
> by default.  If both the PF and VFs are running with a driver with that
> commit the administrator may set the module param to true.
> 
> The module parameter is called enable_4k_uar.
> 
> Fixes: 85743f1eb345 ('net/mlx4_core: Set UAR page size to 4KB ...')
> Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
