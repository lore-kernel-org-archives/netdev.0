From: Sowmini Varadhan <sowmini.varadhan-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] RDS: TCP: Delete an error message for a failed
 memory allocation in rds_tcp_init_net()
Date: Mon, 22 May 2017 10:26:51 -0400
Message-ID: <20170522142651.GA29434@oracle.com>
References: <44b46c51-3665-5f14-dd3b-6e6f230258a7@users.sourceforge.net>
 <5d523cf8-1540-e704-2301-a5e0205cb536@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5d523cf8-1540-e704-2301-a5e0205cb536-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On (05/22/17 16:13), SF Markus Elfring wrote:
> 
> Omit an extra message for a memory allocation failure in this function.

The change itself is harmless,  but I'm curious about the "extra"
part: "extra" from what? If this happens, hopefully this will be logged
somewhere? Note that this type of (infrequent) logging noise is useful
in some cases, e.g., with 8ce675ff, when one is trying to do the
post-mortem of where things first went wrong.

--Sowmini

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
