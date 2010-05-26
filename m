From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH] net/core: use net_device dev_id to indicate port number
Date: Wed, 26 May 2010 19:09:19 +0300
Message-ID: <20100526160919.GA11096@mtldesk030.lab.mtl.com>
References: <20100526095200.GA7370@mtldesk030.lab.mtl.com>
	<20100526082306.25959fb6@nehalam>
	<20100526152730.GA10890@mtldesk030.lab.mtl.com>
	<20100526083318.5b7b7704@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100526083318.5b7b7704@nehalam>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, May 26, 2010 at 08:33:18AM -0700, Stephen Hemminger wrote:
> 
> SET_NETDEV_DEV macro exists because at the time 2.5 kernel was being developed
> it was important to be able to maintain source compatibility between 2.4 and
> 2.6 (nee 2.5) drivers. Since 2.4 did not have sysfs, the macro was a mechanism
> to allow the same code to run on both kernel versions.
> 
> Your situation is different, just use dev_id and update documentation if
> you need to.
> 

OK, great. Things get much much simpler :-)
I'll send another patch for mlx4_en only.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
