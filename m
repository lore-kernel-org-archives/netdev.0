From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] mlx4_en: show device's port used
Date: Tue, 25 May 2010 10:12:06 -0700
Message-ID: <20100525101206.5451346c@nehalam>
References: <20100525135548.GA12749@mtldesk030.lab.mtl.com>
	<adaaarnzzsc.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux RDMA list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <adaaarnzzsc.fsf-BjVyx320WGW9gfZ95n9DRSW4+XlvGpQz@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 25 May 2010 09:55:47 -0700
Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org> wrote:

>  > Add a sysfs file under /sys/class/net/<ethx> to show the port number within the
>  > device that this network interface is using. This is needed as ConnectX devices
>  > have two ports and it is useful to know which port the ethernet devices uses.
> 
> How do other multi-port ethernet devices handle this?  Seems that the
> cleanest way to handle this would be to add a place for drivers to set
> the port number, and export it to userspace in generic code (so everyone
> does it the same way).

There is a rarely used field in net_device called dev_id
that looks like it was intended for this.


-- 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
