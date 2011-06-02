From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dm9000: Get the chip in a known good state before
 enabling interrupts
Date: Wed, 01 Jun 2011 21:22:28 -0700 (PDT)
Message-ID: <20110601.212228.922080759961103808.davem@davemloft.net>
References: <1306959489-28865-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben-linux@fluff.org, netdev@vger.kernel.org
To: broonie@opensource.wolfsonmicro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab1FBEWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 00:22:45 -0400
In-Reply-To: <1306959489-28865-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Date: Wed,  1 Jun 2011 21:18:09 +0100

> Currently the DM9000 driver requests the primary interrupt before it
> resets the chip and puts it into a known good state. This means that if
> the chip is asserting interrupt for some reason we can end up with a
> screaming IRQ that the interrupt handler is unable to deal with. Avoid
> this by only requesting the interrupt after we've reset the chip so we
> know what state it's in.
> 
> This started manifesting itself on one of my boards in the past month or
> so, I suspect as a result of some core infrastructure changes removing
> some form of mitigation against bad behaviour here, even when things boot
> it seems that the new code brings the interface up more quickly.
> 
> Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>

Applied, thanks.
