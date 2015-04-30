From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Fix RGMII-ID mode
Date: Thu, 30 Apr 2015 16:49:12 -0400 (EDT)
Message-ID: <20150430.164912.1699155158792270511.davem@davemloft.net>
References: <1430406470-26907-1-git-send-email-mpa@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: festevam@gmail.com, B38611@freescale.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, kernel@pengutronix.de
To: mpa@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbbD3UtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 16:49:15 -0400
In-Reply-To: <1430406470-26907-1-git-send-email-mpa@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>
Date: Thu, 30 Apr 2015 17:07:50 +0200

> RGMII-ID uses an internal delay within the transmitter or receiver. This
> feature is phy specific. The rest of the communication is normal RGMII.
> 
> So the fec driver has to check for all RGMII modes, not only
> 'PHY_INTERFACE_MODE_RGMII'.
> 
> Signed-off-by: Markus Pargmann <mpa@pengutronix.de>

Applied, thank you.
