From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] e1000e: Fix irq_synchronize in MSI-X
 case
Date: Mon, 02 Aug 2010 21:21:18 -0700 (PDT)
Message-ID: <20100802.212118.149832529.davem@davemloft.net>
References: <20100803002622.4179.31850.stgit@localhost.localdomain>
	<20100803002721.4179.75916.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	jdelvare@suse.de, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60610
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754185Ab0HCEVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 00:21:00 -0400
In-Reply-To: <20100803002721.4179.75916.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 02 Aug 2010 17:27:23 -0700

> Based on original patch/work from Jean Delvare <jdelvare@suse.de>
> Synchronize all IRQs when in MSI-X IRQ mode.
> 
> Jean's original patch hard coded the sync with the 3 possible vectors,
> this patch incorporates more flexibility for the future and aligns
> with how igb stores the number of vectors into the adapter structure.
> 
> CC: Jean Delvare <jdelvare@suse.de>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Acked-by: Bruce Allan <bruce.w.allan@intel.com>

Applied.
