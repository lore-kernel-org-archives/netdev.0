From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 15/15] i40iw: changes for build of i40iw module
Date: Wed, 16 Dec 2015 12:53:16 -0800
Message-ID: <20151216205316.GA21948@infradead.org>
References: <1450295919-17292-7-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-8-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-9-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-10-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-11-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-12-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-13-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-14-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-15-git-send-email-faisal.latif@intel.com>
 <1450295919-17292-16-git-send-email-faisal.latif@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1450295919-17292-16-git-send-email-faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> --- a/include/uapi/rdma/rdma_netlink.h
> +++ b/include/uapi/rdma/rdma_netlink.h
> @@ -5,6 +5,7 @@
>  
>  enum {
>  	RDMA_NL_RDMA_CM = 1,
> +	RDMA_NL_I40IW,
>  	RDMA_NL_NES,
>  	RDMA_NL_C4IW,
>  	RDMA_NL_LS,	/* RDMA Local Services */

This changes the values for the existing RDMA_NL_NES, RDMA_NL_C4IW and
RDMA_NL_LS symbols.  Please add your new value at the end.  And it
should probably be a separate patch as it's not related to the build
system and referenced by the earlier patches.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
