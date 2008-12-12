From: Joerg Roedel <joerg.roedel@amd.com>
Subject: Re: [NET-NEXT PATCH] ixgbe: fix dma mapping unbalance
Date: Fri, 12 Dec 2008 12:31:47 +0100
Message-ID: <20081212113147.GE30292@amd.com>
References: <20081212095104.4380.49487.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-wa4.frontbridge.com ([216.32.181.16]:38857 "EHLO
	WA4EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755700AbYLLLcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 06:32:04 -0500
Content-Disposition: inline
In-Reply-To: <20081212095104.4380.49487.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nice. I discoverd a couple more bugs in this driver while testing my
IOMMU code.
One bug can only be found with an hardware IOMMU. This seems to be a
use-after-free bug, at least I see IO_PAGE_FAULTS from the IOMMU
originating from this card. Maybe you can change the VT-d code so that
you can debug this issue.
I didn't found the time yet to do a v2 of my DMA-API debugging patches.
But I hope can will the time for this next week. Then you have something
in hand to debug the driver even further :)

Joerg

On Fri, Dec 12, 2008 at 01:51:05AM -0800, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> This issue was initially reported by Joerg Roedel <joerg.roedel@amd.com>
> It appears that ixgbe has had a long standing bug where it was
> unmapping a different size than it had mapped.

-- 
           |           AMD Saxony Limited Liability Company & Co. KG
 Operating |         Wilschdorfer Landstr. 101, 01109 Dresden, Germany
 System    |                  Register Court Dresden: HRA 4896
 Research  |              General Partner authorized to represent:
 Center    |             AMD Saxony LLC (Wilmington, Delaware, US)
           | General Manager of AMD Saxony LLC: Dr. Hans-R. Deppe, Thomas McCoy

