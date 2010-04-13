From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bcm63xx_enet: do not overwrite ENET_CTL_REG value
Date: Tue, 13 Apr 2010 03:30:30 -0700 (PDT)
Message-ID: <20100413.033030.144455634.davem@davemloft.net>
References: <201004091304.52540.ffainelli@freebox.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mbizon@freebox.fr
To: ffainelli@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46131
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753008Ab0DMKa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:30:26 -0400
In-Reply-To: <201004091304.52540.ffainelli@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <ffainelli@freebox.fr>
Date: Fri, 9 Apr 2010 13:04:52 +0200

> bcm_enet_hw_preinit will correctly set values in ENET_CTL_REG for internal
> or external MII operations, however, bcm_enet_open will blindly overwrite the
> ENET_CTL_REG register value and thus we will loose any changes to it that
> were made in bcm_enet_hw_preinit, rendering external MII operations non-working.
> 
> This would lead to the driver not being able to check for link availability on
> external PHY setups, and thus we would never get to sending packets because
> link was down from the driver side.
> 
> This was completely un-noticed because all boards out there but BCM6338-based
> ones use internal phy on their enet0 interface.
> 
> Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>

Applied.
