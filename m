From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH] net/core: Save the port number a netdevice uses
Date: Wed, 26 May 2010 11:45:23 +0300
Message-ID: <20100526084523.GA28748@mtldesk030.lab.mtl.com>
References: <20100526081702.GA17160@mtldesk030.lab.mtl.com>
	<20100526.013926.28807066.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100526.013926.28807066.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, May 26, 2010 at 01:39:26AM -0700, David Miller wrote:
> From: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
> Date: Wed, 26 May 2010 11:17:02 +0300
> 
> > Today, there are no means to know which port of a hardware device a netdev
> > interface uses. This patch adds a new field to struct net_device that is used
> > to store this value. The network driver should use the SET_NETDEV_PORT_NUM()
> > macro to set the port number for the device it manages. For drivers that do not
> > set a value, a default value of 1 is set at alloc_netdev_mq().
> > This patch also makes use of this feature in the mlx4_en driver.
> > 
> > Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
> 
> We have an existing dev_id, use it.

Do you think we should use dev_id also for the sysfs file name so
every driver can choose to interpret this field as it chooses to, or
should I keep the sysfs file name as "port_number"?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
