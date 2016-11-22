From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: Re: [RFC 02/10] IB/hfi-vnic: Virtual Network Interface Controller
 (VNIC) Bus driver
Date: Tue, 22 Nov 2016 11:49:18 -0800
Message-ID: <20161122194918.GA69241@knc-06.sc.intel.com>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <1479508938-63799-3-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161119190445.GG22775@obsidianresearch.com>
 <20161121213017.GB67872@knc-06.sc.intel.com>
 <20161121213930.GA30111@obsidianresearch.com>
 <20161121232629.GA67988@knc-06.sc.intel.com>
 <20161121233118.GA31132@obsidianresearch.com>
 <20161122015304.GB67988@knc-06.sc.intel.com>
 <20161122170407.GE3956@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org,
        Dennis Dalessandro <dennis.dalessandro@intel.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:43284 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754970AbcKVTtn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 14:49:43 -0500
Content-Disposition: inline
In-Reply-To: <20161122170407.GE3956@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, I do understand Jason's point that we should probably not put this driver 
under drivers/infiniband/sw/.., as this driver is not a HCA.
It is an ULP similar to ipoib, built on top of Omni-path irrespective of 
whether we register a hfi_vnic_bus or a direct custom interface with HFI1.
This ULP will transmit and recieve Omni-path packets over the fabric, and is 
dependent on IB MAD interface and the HFI1 driver.

Doug,
Will it be acceptable if we put it under 'drivers/infiniband/ulp/hfi_vnic'?

Niranjana
