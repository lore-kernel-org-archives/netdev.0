From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] ixgbe: enable extremely low latency
Date: Tue, 27 Apr 2010 12:56:00 -0700 (PDT)
Message-ID: <20100427.125600.184829198.davem@davemloft.net>
References: <20100427113651.24431.9221.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49596
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756777Ab0D0Tzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 15:55:54 -0400
In-Reply-To: <20100427113651.24431.9221.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Apr 2010 04:37:20 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> 82598/82599 can support EITR == 0, which allows for the
> absolutely lowest latency setting in the hardware.  This disables
> writeback batching and anything else that relies upon a delayed
> interrupt. This patch enables the feature of "override" when a
> user sets rx-usecs to zero, the driver will respect that setting
> over using RSC, and automatically disable RSC.  If rx-usecs is
> used to set the EITR value to 0, then the driver should disable
> LRO (aka RSC) internally until EITR is set to non-zero again.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
