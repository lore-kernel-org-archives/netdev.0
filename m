From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) Bus driver
Date: Tue, 29 Nov 2016 09:19:50 -0700
Message-ID: <20161129161950.GB742@obsidianresearch.com>
References: <20161121233118.GA31132@obsidianresearch.com>
 <20161122015304.GB67988@knc-06.sc.intel.com>
 <20161122170407.GE3956@obsidianresearch.com>
 <20161123000502.GA27968@phlsvsds.ph.intel.com>
 <20161123004932.GA13598@obsidianresearch.com>
 <20161124000825.GA73280@knc-06.sc.intel.com>
 <20161124161545.GA20818@obsidianresearch.com>
 <20161125021350.GA74946@knc-06.sc.intel.com>
 <20161125190509.GB16504@obsidianresearch.com>
 <20161129063106.GB84990@knc-06.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161129063106.GB84990-wPcXA7LoDC+1XWohqUldA0EOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 10:31:06PM -0800, Vishwanathapura, Niranjana wrote:
> On Fri, Nov 25, 2016 at 12:05:09PM -0700, Jason Gunthorpe wrote:
> >On Thu, Nov 24, 2016 at 06:13:50PM -0800, Vishwanathapura, Niranjana wrote:
> >
> >>In order to be truely device independent the hfi_vnic ULP should not depend
> >>on a device exported symbol. Instead device should register its functions
> >>with the ULP. Hence the approaches a) and b).
> >
> >It is not device independent, it is hard linked to hfi1, just like our
> >other multi-component drivers.. So don't worry about that.
> >
> 
> We would like to keep the design clean and avoid any tight coupling here
> (our original design in this series tackled these).
> Any strong reason not to go with a) or b) ?

You are not making a subsystem. Don't overcomplicate things. A
multi-part device device can just directly link.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
