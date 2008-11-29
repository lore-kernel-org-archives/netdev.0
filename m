From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: power management support
Date: Fri, 28 Nov 2008 16:33:06 -0800 (PST)
Message-ID: <20081128.163306.139388123.davem@davemloft.net>
References: <1227794220-19872-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49393
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753001AbYK2AdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 19:33:06 -0500
In-Reply-To: <1227794220-19872-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 27 Nov 2008 14:57:00 +0100

> This patch adds the power management support into the physical
> abstraction layer.
> 
> Suspend and resume functions respectively turns on/off the bit 11
> into the PHY Basic mode control register.
> Generic PHY device starts supporting PM.
> 
> In order to support the wake-on LAN and avoid to put in power down
> the PHY device, the MDIO is aware of what the Ethernet device wants to do.
> 
> Voluntary, no CONFIG_PM defines were added into the sources.
> Also generic suspend/resume functions are exported to allow
> other drivers use them (such as genphy_config_aneg etc.).
> 
> Within the phy_driver_register function, we need to remove the
> memset. It overrides the device driver owner and it is not good.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.

We should audit all of the phy_driver_register() callers to make
sure the removal of that memset() won't cause any problems.
