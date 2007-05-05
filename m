From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/11][TG3]: Remove reset during MAC address changes.
Date: Sat, 05 May 2007 12:10:38 -0700 (PDT)
Message-ID: <20070505.121038.41702323.davem@davemloft.net>
References: <1178326378.4859.21.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35753
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933120AbXEETKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 15:10:51 -0400
In-Reply-To: <1178326378.4859.21.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 04 May 2007 17:52:58 -0700

> [TG3]: Remove reset during MAC address changes.
> 
> The reset was added a while back so that ASF could re-init whatever
> MAC address it wanted to use after the MAC address was changed.
> Instead of resetting, we can just keep MAC address 1 unchanged during
> MAC address changes if MAC address 1 is different from MAC address 0.
> 
> This fixes 2 problems:
> 
> 1. Bonding calls set_mac_address in contexts that cannot sleep.
> It no longer sleeps with the chip reset removed.

This is arguably a bonding bug.

> 2. When ASF shares the same MAC address as the NIC, it needs to
> always do that even when the MAC address is changed. 
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> 

Applied, thanks.
