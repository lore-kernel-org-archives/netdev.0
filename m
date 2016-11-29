From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) Bus driver
Date: Tue, 29 Nov 2016 09:50:09 -0700
Message-ID: <20161129165009.GA3167@obsidianresearch.com>
References: <20161122170407.GE3956@obsidianresearch.com>
 <20161123000502.GA27968@phlsvsds.ph.intel.com>
 <20161123004932.GA13598@obsidianresearch.com>
 <20161124000825.GA73280@knc-06.sc.intel.com>
 <20161124161545.GA20818@obsidianresearch.com>
 <20161125021350.GA74946@knc-06.sc.intel.com>
 <20161125190509.GB16504@obsidianresearch.com>
 <20161129063106.GB84990@knc-06.sc.intel.com>
 <20161129161950.GB742@obsidianresearch.com>
 <1828884A29C6694DAF28B7E6B8A82373AB0B9B46@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>,
        "Weiny, Ira" <ira.weiny@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Dalessandro, Dennis" <dennis.dalessandro@intel.com>
To: "Hefty, Sean" <sean.hefty@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:54790 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756379AbcK2QuM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 11:50:12 -0500
Content-Disposition: inline
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373AB0B9B46@ORSMSX109.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 04:44:37PM +0000, Hefty, Sean wrote:
> > You are not making a subsystem. Don't overcomplicate things. A
> > multi-part device device can just directly link.
> 
> The VNIC may be usable over multiple generations of HFIs, but I
> don't know if that is the intent.

If Intel wants to build a HFI subystem within RDMA with multiple
drivers then sure, but they are not there yet, and we don't even know
what that could look like. So it is better to leave it simple for now.

Jason
