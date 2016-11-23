From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) Bus driver
Date: Wed, 23 Nov 2016 01:06:43 +0100
Message-ID: <20161123000643.GJ2691@lunn.ch>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1479508938-63799-3-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161119190445.GG22775@obsidianresearch.com>
 <20161121213017.GB67872@knc-06.sc.intel.com>
 <20161121213930.GA30111@obsidianresearch.com>
 <20161121232629.GA67988@knc-06.sc.intel.com>
 <20161121233118.GA31132@obsidianresearch.com>
 <20161122015304.GB67988@knc-06.sc.intel.com>
 <20161122170407.GE3956@obsidianresearch.com>
 <20161122194918.GA69241@knc-06.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org,
        Dennis Dalessandro <dennis.dalessandro@intel.com>
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49078 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751968AbcKWAHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 19:07:25 -0500
Content-Disposition: inline
In-Reply-To: <20161122194918.GA69241@knc-06.sc.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 11:49:18AM -0800, Vishwanathapura, Niranjana wrote:
> Ok, I do understand Jason's point that we should probably not put
> this driver under drivers/infiniband/sw/.., as this driver is not a
> HCA.
> It is an ULP similar to ipoib, built on top of Omni-path
> irrespective of whether we register a hfi_vnic_bus or a direct
> custom interface with HFI1.
> This ULP will transmit and recieve Omni-path packets over the
> fabric, and is dependent on IB MAD interface and the HFI1 driver.
> 
> Doug,
> Will it be acceptable if we put it under 'drivers/infiniband/ulp/hfi_vnic'?

How about turning this whole discussion around. 

This is a network driver. So ask the network Maintainers where he
wants it. Send the patch to David Miller <davem@davemloft.net> and
netdev with the question, where does this code belong?

	Andrew
