From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2] IB/rds: Correct ib_api use with
 gs_dma_address/sg_dma_len
Date: Wed, 26 Dec 2012 15:21:44 -0800 (PST)
Message-ID: <20121226.152144.969735716097168682.davem@davemloft.net>
References: <20121221175857.23716.46975.stgit@phlsvslse11.ph.intel.com>
	<20121221180149.23716.54707.stgit@phlsvslse11.ph.intel.com>
	<50D997D0.2020004@acm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mike.marciniszyn-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: bvanassche-HInyCGIudOg@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <50D997D0.2020004-HInyCGIudOg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Date: Tue, 25 Dec 2012 13:10:56 +0100

> The above patch will slow down RDS for anyone who is not using QLogic
> HCA's, isn' it ? How about replacing the above patch with the
> (untested) patch below ?

I agree with your suggestion but do this kind of simplification in
the next merge window, not now.

That's why I applied Mike's patches as-is.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
