From: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V1 00/16] add Intel(R) X722 iWARP driver
Date: Thu, 24 Dec 2015 01:25:15 -0600
Message-ID: <20151224072515.GA35696@flatif-MOBL1>
References: <1450739596-23276-1-git-send-email-faisal.latif@intel.com>
 <567AD444.10204@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <567AD444.10204-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 23, 2015 at 09:05:08AM -0800, Or Gerlitz wrote:
> On 12/22/2015 1:13 AM, Faisal Latif wrote:
> > This driver provides iWARP RDMA functionality for the Intel(R) X722 Ethernet
> > controller for PCI Physical Functions.
> 
> Is there any public info on the X722, I didn't manage to find such.

it is not yet available as it is in early product cycle with the intent of getting initial
support into the kernel before users have the hardware available to purchase.
> 
> > It also has support for Virtual Function driver (i40iwvf.ko), which that will be part of separate patch series.
> 
> can you explain why do you need a separate rdma driver for VFs?

The VF driver (i40iwvf.ko) requires PF driver (i40iw.ko) to work. I will add more in the
cover page of the patch series.
> 
> Or.

Thanks
Faisal
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
