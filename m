From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] e1000: fix Tx hangs by disabling 64-bit
 DMA
Date: Wed, 08 Sep 2010 14:22:07 -0700 (PDT)
Message-ID: <20100908.142207.258102173.davem@davemloft.net>
References: <20100908065835.315.15437.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60899
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755589Ab0IHVVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 17:21:49 -0400
In-Reply-To: <20100908065835.315.15437.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 08 Sep 2010 00:01:12 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Several users report issues with 32-bit adapters when plugged
> into PCI slots in machines with >= 4GB ram.  In particular AMD
> systems with HyperTransport to PCI bridges seem to trigger the
> issue, but it isn't limited to only them.
> 
> This issue is not easily reproducible here, yet still continues
> to occur in the field.  For e1000 on PCI devices, just disable DMA
> addresses over the 4GB boundary when in PCI (not PCI-X) mode, to
> prevent the issue from continuing to pop up.  The performance
> impact for this is negligible.
> 
> The code was refactored to move the init of the hw struct to its
> own function. This allows the init to be called very early in
> probe, which then allows using hw-> members for this fix.
> 
> A slight refactor to the DMA mask code was done for minor
> correctness based on the instructions in DMA-API-HOWTO.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks guys.
