From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) Bus driver
Date: Tue, 22 Nov 2016 10:04:07 -0700
Message-ID: <20161122170407.GE3956@obsidianresearch.com>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1479508938-63799-3-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161119190445.GG22775@obsidianresearch.com>
 <20161121213017.GB67872@knc-06.sc.intel.com>
 <20161121213930.GA30111@obsidianresearch.com>
 <20161121232629.GA67988@knc-06.sc.intel.com>
 <20161121233118.GA31132@obsidianresearch.com>
 <20161122015304.GB67988@knc-06.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org,
        Dennis Dalessandro <dennis.dalessandro@intel.com>
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:48895 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756021AbcKVREL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 12:04:11 -0500
Content-Disposition: inline
In-Reply-To: <20161122015304.GB67988@knc-06.sc.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2016 at 05:53:04PM -0800, Vishwanathapura, Niranjana wrote:
> There are many example drivers in kernel which are using bus_register() in
> an initcall.

There really are not, certainly not in major subsystems.

> We could add a custom Interface between HFI1 driver and hfi_vnic drivers
> without involving a bus.

hfi is already registering on the infiniband class, just use that.

> But using the existing bus model gave a lot of in-built flexibility in
> decoupling devices from the drivers.

If you want to have your own bus then you need your own hfi
subsystem. drivers/infiniband is not a dumping ground..

Jason
