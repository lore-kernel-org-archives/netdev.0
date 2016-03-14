From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: fix default configuration for GMAC on AT91
Date: Sun, 13 Mar 2016 22:20:11 -0400 (EDT)
Message-ID: <20160313.222011.1724698990540701829.davem@davemloft.net>
References: <1457624672-30666-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	cyrille.pitchen@atmel.com, linux-kernel@vger.kernel.org,
	alexandre.belloni@free-electrons.com,
	boris.brezillon@free-electrons.com, romain.henriet@l-acoustics.com,
	michal.simek@xilinx.com, punnaia@xilinx.com
To: nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbcCNCUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 22:20:16 -0400
In-Reply-To: <1457624672-30666-1-git-send-email-nicolas.ferre@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Thu, 10 Mar 2016 16:44:32 +0100

> On AT91 SoCs, the User Register (USRIO) exposes a switch to configure the
> "Reduced" or "Traditional" version of the Media Independent Interface
> (RMII vs. MII or RGMII vs. GMII).
> As on the older EMAC version, on GMAC, this switch is set by default to the
> non-reduced type of interface, so use the existing capability and extend it to
> GMII as well. We then keep the current logic in the macb_init() function.
> 
> The capabilities of sama5d2, sama5d4 and sama5d3 GEM interface are updated in
> the macb_config structure to be able to properly enable them with a traditional
> interface (GMII or MII).
> 
> Reported-by: Romain HENRIET <romain.henriet@l-acoustics.com>
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Applied.
