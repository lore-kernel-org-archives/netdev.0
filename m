From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000e: 82577/82578 PHY register access issues
Date: Tue, 27 Jul 2010 21:06:42 -0700 (PDT)
Message-ID: <20100727.210642.137855605.davem@davemloft.net>
References: <20100727222808.25500.11033.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	stable@kernel.org, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42976
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750806Ab0G1EGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 00:06:25 -0400
In-Reply-To: <20100727222808.25500.11033.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Jul 2010 15:28:46 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The MAC-PHY interconnect on 82577/82578 uses a power management feature
> (called K1) which must be disabled when in 1Gbps due to a hardware issue on
> these parts.  The #define bit setting used to enable/disable K1 is
> incorrect and can cause PHY register accesses to stop working altogether
> until the next device reset.  This patch sets the register correctly.
> 
> This issue is present in kernels since 2.6.32.
> 
> CC: stable@kernel.org
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
