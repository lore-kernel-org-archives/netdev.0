From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH] mlx4_en: show device's port used
Date: Tue, 25 May 2010 20:42:14 +0300
Message-ID: <20100525174214.GA14745@mtldesk030.lab.mtl.com>
References: <20100525135548.GA12749@mtldesk030.lab.mtl.com>
	<adaaarnzzsc.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux RDMA list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <adaaarnzzsc.fsf-BjVyx320WGW9gfZ95n9DRSW4+XlvGpQz@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 25, 2010 at 09:55:47AM -0700, Roland Dreier wrote:
> 
> How do other multi-port ethernet devices handle this?
I don't think there are many devices out there which have more than
one port.

>  Seems that the
> cleanest way to handle this would be to add a place for drivers to set
> the port number,
So this will require changing all the drivers to put some value there
or we would need to use a default value of 1 for drivers that don't
explicitly set a value.

> and export it to userspace in generic code (so everyone
> does it the same way).
Something like ethtool? But we still need an entry under
/sys/class/net/ethx/, right?
 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
