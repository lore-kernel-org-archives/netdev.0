From: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 00/16] add Intel X722 iWARP driver
Date: Mon, 4 Apr 2016 12:59:21 -0500
Message-ID: <20160404175921.GA10356@flatif-MOBL1>
References: <1453318816-21672-1-git-send-email-faisal.latif@intel.com>
 <20160404073929.GA23218@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160404073929.GA23218-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 04, 2016 at 12:39:29AM -0700, Christoph Hellwig wrote:
> On Wed, Jan 20, 2016 at 01:40:00PM -0600, Faisal Latif wrote:
> > This driver provides iWARP RDMA functionality for the Intel(R) X722 Ethernet
> > controller for PCI Physical Functions. It is in early product cycle
> > and having the driver in the kernel will allow users to have hardware support
> > when available for purchase.
> 
> Just curious: how is this driver supposed to work?  It doesn't seem to
> support FRWRs despite the iWarp spec requiring support for it.  It also
> sets IB_DEVICE_MEM_MGT_EXTENSIONS despite the lack of this methods,
> which will lead to instant crashes when using any of the usual drivers.
> 

Thank Christoph,

We are addressing it in the next patch series.

Faisal
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
