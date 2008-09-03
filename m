From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET-NEXT PATCH 01/13] ixgbe: fix rx csum return status	misinterpretation
Date: Wed, 03 Sep 2008 10:03:51 -0400
Message-ID: <48BE9947.4060703@garzik.org>
References: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60048 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752968AbYICODy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:03:54 -0400
In-Reply-To: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> the driver was misinterpreting rx_csum return value in the descriptor
> so occassionally we would indicate an rx_csum error in our stats
> when there was none.  This would have no effect on traffic because
> we would just hand the packet to the stack anyway without the offload
> flag set, but would increase CPU for those packets that needed a recompute.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe_main.c |    8 +++-----
>  1 files changed, 3 insertions(+), 5 deletions(-)

applied 1-13


