From: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] net/mlx4_core: Fix backward compatibility on VFs
Date: Sun, 20 Mar 2016 09:07:59 +0200
Message-ID: <20160320070759.GA2935@yuval-lap.uk.oracle.com>
References: <1458233382-12871-1-git-send-email-eli@mellanox.com>
 <20160318.231106.2099055485546956238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, aik-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org
To: eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160318.231106.2099055485546956238.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 18, 2016 at 11:11:06PM -0400, David Miller wrote:
> From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Date: Thu, 17 Mar 2016 18:49:42 +0200
> 
> > Commit 85743f1eb345 ("net/mlx4_core: Set UAR page size to 4KB regardless
> > of system page size") introduced dependency where old VF drivers without
> > this fix fail to load if the PF driver runs with this commit.
> > 
> > To resolve this add a module parameter which disables that functionality
> > by default.  If both the PF and VFs are running with a driver with that
> > commit the administrator may set the module param to true.
> > 
> > The module parameter is called enable_4k_uar.
Can you consider passing this via comm-channel and save us all from new
module parameter?
Suggesting this from sys-admin perspective where (1) making this consist in
VF and **all** guests would me a nightmare and also (2) take into account
in public cloud that hypervisor sys-admin is not necessary the same person
as guest sys-admin.
> > 
> > Fixes: 85743f1eb345 ('net/mlx4_core: Set UAR page size to 4KB ...')
> > Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> 
> Applied.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
