From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) Bus driver
Date: Tue, 22 Nov 2016 17:04:37 -0600 (CST)
Message-ID: <alpine.DEB.2.20.1611221656390.8214@east.gentwo.org>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com> <1479508938-63799-3-git-send-email-niranjana.vishwanathapura@intel.com> <20161119190445.GG22775@obsidianresearch.com> <20161121213017.GB67872@knc-06.sc.intel.com>
 <20161121213930.GA30111@obsidianresearch.com> <20161121232629.GA67988@knc-06.sc.intel.com> <20161121233118.GA31132@obsidianresearch.com> <20161122015304.GB67988@knc-06.sc.intel.com> <20161122170407.GE3956@obsidianresearch.com>
 <20161122194918.GA69241@knc-06.sc.intel.com>
Content-Type: text/plain; charset=US-ASCII
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161122194918.GA69241-wPcXA7LoDC+1XWohqUldA0EOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Nov 2016, Vishwanathapura, Niranjana wrote:

> Ok, I do understand Jason's point that we should probably not put this driver
> under drivers/infiniband/sw/.., as this driver is not a HCA.
> It is an ULP similar to ipoib, built on top of Omni-path irrespective of
> whether we register a hfi_vnic_bus or a direct custom interface with HFI1.
> This ULP will transmit and recieve Omni-path packets over the fabric, and is
> dependent on IB MAD interface and the HFI1 driver.

This is something that encapsulates IP (v4 right?) in something else.
Would belong into

	linux/net/ipv4

You already have similar implementations there

See f.e. ipip.c, ip_tunnel.c and lots more (try
	ls linux/net/ipv4/*tunnel*

)

If this is more like a device then it would belong into

linux/drivers/net/hfi or so (see also linux/drivers/net/ppp, plip,
loopback, etc etc)



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
