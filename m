From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [RFC v2 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) interface
Date: Thu, 15 Dec 2016 00:56:24 -0800
Message-ID: <20161215085624.GA6824@infradead.org>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1481788782-89964-3-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215085349.GA90068@knc-06.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161215085349.GA90068-wPcXA7LoDC+1XWohqUldA0EOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 12:53:49AM -0800, Vishwanathapura, Niranjana wrote:
> On Wed, Dec 14, 2016 at 11:59:34PM -0800, Vishwanathapura, Niranjana wrote:
> > +
> > +static inline bool is_hfi_ibdev(struct ib_device *ibdev)
> > +{
> > +	return !memcmp(ibdev->name, "hfi", 3);
> > +}
> 
> I am thinking of adding a device capability flag to indicate HFI VNIC
> capabilty instead of relying on the device name as above to identify a hfi
> ib deice.

Absolutely.

> Any comments? Probably it can be addressed by a separate patch later.

no, comparing device names is always wrong, please do it ASAP.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
