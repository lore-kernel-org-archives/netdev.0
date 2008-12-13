From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 19/33] sfc: Add support for sub-10G speeds
Date: Fri, 12 Dec 2008 21:50:15 -0800 (PST)
Message-ID: <20081212.215015.82866395.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212125449.GS10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44216
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754483AbYLMFuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:50:14 -0500
In-Reply-To: <20081212125449.GS10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:54:51 +0000

> The SFC4000 has a separate MAC for use at sub-10G speeds.  Introduce
> an efx_mac_operations structure with implementations for the two MACs.
> Switch between the MACs as necessary.
> 
> PHY settings are independent of the MAC, so add get_settings() and
> set_settings() to efx_phy_operations.  Also add macs field to indicate
> which MACs the PHY is connected to.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
