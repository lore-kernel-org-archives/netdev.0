From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] e1000e: fix packet corruption and tx hang during NFSv2
Date: Fri, 5 Mar 2010 08:18:25 -0500
Message-ID: <20100305131825.GB17483@hmsreliant.think-freely.org>
References: <20100305122131.8250.21132.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59563 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab0CENSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 08:18:30 -0500
Content-Disposition: inline
In-Reply-To: <20100305122131.8250.21132.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 05, 2010 at 04:21:44AM -0800, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> when receiving a particular type of NFS v2 UDP traffic, the hardware could
> DMA some bad data and then hang, possibly corrupting memory.
> 
> Disable the NFS parsing in this hardware, verified to fix the bug.
> 
> Originally reported and reproduced by RedHat's Neil Horman
> CC: nhorman@tuxdriver.com
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>

