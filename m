From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] phylib: Allow early-out in phy_change
Date: Mon, 13 Apr 2009 14:52:10 -0700 (PDT)
Message-ID: <20090413.145210.265793440.davem@davemloft.net>
References: <1239105703-26240-1-git-send-email-agust@denx.de>
	<1239105703-26240-2-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com
To: agust@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40012
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751467AbZDMVwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 17:52:19 -0400
In-Reply-To: <1239105703-26240-2-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anatolij Gustschin <agust@denx.de>
Date: Tue,  7 Apr 2009 14:01:42 +0200

> Marvell 88E1121R Dual PHY device can be hardware-configured
> to use shared interrupt pin for both PHY ports. For such
> PHY configurations using shared PHY interrupt phy_interrupt()
> handler will also schedule a work for PHY port which didn't
> cause an interrupt.
> 
> This patch adds a possibility for PHY drivers to provide
> did_interrupt() function which reports if the PHY (or a PHY
> port in a multi-PHY device) generated an interrupt. This
> function is called in phy_change() as phy_change() shouldn't
> proceed if it is invoked for a PHY which didn't cause an
> interrupt. So check for interrupt originator in phy_change()
> to allow early-out.
> 
> Signed-off-by: Anatolij Gustschin <agust@denx.de>

Applied.

> +	 * For multy-PHY devices with shared PHY interrupt pin
               ^^^^^

I fixed that typo when commiting this change.
