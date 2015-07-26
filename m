From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv6 RFT] net: fec: Ensure clocks are enabled while using
 mdio bus
Date: Sun, 26 Jul 2015 18:36:23 +0200
Message-ID: <20150726163623.GF2385@lunn.ch>
References: <1437856682-2338-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lucas Stach <l.stach@pengutronix.de>, tyler.baker@linaro.org,
	fabio.estevam@freescale.com, shawn.guo@linaro.org,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47730 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755199AbbGZQnP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jul 2015 12:43:15 -0400
Content-Disposition: inline
In-Reply-To: <1437856682-2338-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 25, 2015 at 10:38:02PM +0200, Andrew Lunn wrote:
> When a switch is attached to the mdio bus, the mdio bus can be used
> while the interface is not open. If the IPG clock is not enabled, MDIO
> reads/writes will simply time out.

Hi David

Now there are two tested-by's could you pick this patch up?

Or do you want a repost including the tested-by's?

Thanks
	Andrew
