From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Thu, 15 Dec 2016 10:07:13 -0700
Message-ID: <20161215170713.GD3264@obsidianresearch.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215091226.GC811@mtr-leonro.local>
 <20161215145212.GA29116@phlsvsds.ph.intel.com>
 <380b05bf-a18e-1f20-7e8e-10b61f77dec7@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <380b05bf-a18e-1f20-7e8e-10b61f77dec7-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 11:28:06AM -0500, Doug Ledford wrote:

> 1) Since your intent is to make this work with multiple versions of the
> hfi drivers, I disagree with Jason that just because there is only one
> driver today that we should keep it simple.  Design it right from the
> beginning of multi driver is your intent is, IMO, a better way to go.
> You'll work out the bugs in the initial implementation and when it comes
> time to add the second driver, things will go much more smoothly.

If that is your position then this should be a straight up IB ULP that
works with any IB hardware.

There is nothing HFI specific about it except for the
micro-optimization of pushing packets via SDMA instead of post_send,
and that same micro optimization probably applies to ipoib.

In other words, lets see the first version as a straight ULP with no
special HFI hooks, then we can discuss how best to micro optimize it
for HFI SDMA.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
