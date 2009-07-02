From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] phylib: fixes for PHY_RESUMING state changes
Date: Wed, 1 Jul 2009 19:34:24 -0500
Message-ID: <3253A2AC-9D19-4B02-8526-0D460C6E409E@freescale.com>
References: <1246489234.26353.60.camel@rhino>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Wade Farnsworth <wfarnsworth@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:61820 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752951AbZGBAet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 20:34:49 -0400
In-Reply-To: <1246489234.26353.60.camel@rhino>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jul 1, 2009, at 6:00 PM, Wade Farnsworth wrote:

> The PHY_HALTED state disables phydev->link, but the link will not be
> updated upon entering PHY_RESUMING.  Add a call to phy_read_status()  
> to
> update the link before entering PHY_RUNNING.  If the link is not up at
> this point, enter the PHY_NOLINK state instead.
>
> Also, when transitioning from PHY_RESUMING to PHY_RUNNING, calls to
> netif_carrier_on() and phydev->adjust_link() are missing.  Add the  
> calls
> similar to the other transitions to PHY_RUNNING.
>
> Signed-off-by: Wade Farnsworth <wfarnsworth@mvista.com>

Acked-by: Andy Fleming <afleming@freescale.com>
