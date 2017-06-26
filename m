From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH iproute2 3/5] rdma: Add device capability parsing
Date: Mon, 26 Jun 2017 12:29:24 -0600
Message-ID: <20170626182924.GB16026@obsidianresearch.com>
References: <20170626182128.24964-1-leon@kernel.org>
 <20170626182128.24964-4-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170626182128.24964-4-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 26, 2017 at 09:21:26PM +0300, Leon Romanovsky wrote:
> From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> 
> Add parsing interface for the device capability flags
> 
> $ rdma dev show
> 1: mlx5_0: caps 0x1257e1c26

This seems very un ip-like. I wouldn't show an undecoded hex value
like that, it isn't really useful.

> $ rdma dev show mlx5_4 caps
> 5: mlx5_4: caps 0x1257e1c26
> Bit	Description
>  01	DEVICE_BAD_PKEY_CNTR
>  02	DEVICE_BAD_QKEY_CNTR

This table also seems un ip-like, the usual format is a list of words,
I think.

> $ rdma dev show mlx5_4 cap_flags
> Unknown parameter 'caps_flags'.

?

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
