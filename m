From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6 RFT] net: fec: Ensure clocks are enabled while using
 mdio bus
Date: Mon, 27 Jul 2015 01:22:11 -0700 (PDT)
Message-ID: <20150727.012211.1560443681852595377.davem@davemloft.net>
References: <1437856682-2338-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, l.stach@pengutronix.de,
	tyler.baker@linaro.org, fabio.estevam@freescale.com,
	shawn.guo@linaro.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514AbbG0IWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:22:12 -0400
In-Reply-To: <1437856682-2338-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat, 25 Jul 2015 22:38:02 +0200

> When a switch is attached to the mdio bus, the mdio bus can be used
> while the interface is not open. If the IPG clock is not enabled, MDIO
> reads/writes will simply time out.
> 
> Add support for runtime PM to control this clock. Enable/disable this
> clock using runtime PM, with open()/close() and mdio read()/write()
> function triggering runtime PM operations. Since PM is optional, the
> IPG clock is enabled at probe and is no longer modified by
> fec_enet_clk_enable(), thus if PM is not enabled in the kernel, it is
> guaranteed the clock is running when MDIO operations are performed.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>

Applied.
