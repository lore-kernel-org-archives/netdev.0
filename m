From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e100/e1000*/igb*/ixgb*: Add missing read
 memory barrier
Date: Sun, 08 Aug 2010 20:04:03 -0700 (PDT)
Message-ID: <20100808.200403.84396615.davem@davemloft.net>
References: <20100809020230.1087.42749.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	miltonm@bga.com, anton@samba.org, sonnyrao@us.ibm.com,
	stable@kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59395
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755352Ab0HIDDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 23:03:44 -0400
In-Reply-To: <20100809020230.1087.42749.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sun, 08 Aug 2010 19:02:31 -0700

> Based on patches from Sonny Rao and Milton Miller...
> 
> Combined the patches to fix up clean_tx_irq and clean_rx_irq.
> 
> The PowerPC architecture does not require loads to independent bytes
> to be ordered without adding an explicit barrier.
> 
> In ixgbe_clean_rx_irq we load the status bit then load the packet data.
> With packet split disabled if these loads go out of order we get a
> stale packet, but we will notice the bad sequence numbers and drop it.
 ...
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
