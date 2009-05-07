From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 4/5] ixgbe: fix failing to log fan failures
Date: Thu, 07 May 2009 14:56:23 -0700 (PDT)
Message-ID: <20090507.145623.51243600.davem@davemloft.net>
References: <20090507203854.19886.54737.stgit@localhost.localdomain>
	<20090507203954.19886.71138.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34458
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755002AbZEGV42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 17:56:28 -0400
In-Reply-To: <20090507203954.19886.71138.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 07 May 2009 13:39:54 -0700

> We weren't logging the 82598AT fan failure if it occurred before (ixgbe_open)
> as we hadn't sent up to catch the interrupt that event caused.
> 
> This patch checks for this failure in:
> ixgbe_probe - So we can log the failure asap. We check right after we
> set up the adapter->flags, which is when we know that we have a fan.
> ixgbe_up_complete - To catch failures that may have happened between probe
> and when we set up the interrupt that would normally detect the fan failure.
> 
> To enable all of this we need to initialize the adapter flag with
> IXGBE_FLAG_FAN_FAIL_CAPABLE when the NIC contained a fan.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
