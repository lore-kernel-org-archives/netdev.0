From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smc91x: retrieve IRQ and trigger flags in a modern way
Date: Sat, 01 Nov 2014 17:04:39 -0400 (EDT)
Message-ID: <20141101.170439.601714821948738788.davem@davemloft.net>
References: <1414787526-11197-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nico@fluxnic.net
To: linus.walleij@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760399AbaKAVEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 17:04:41 -0400
In-Reply-To: <1414787526-11197-1-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Walleij <linus.walleij@linaro.org>
Date: Fri, 31 Oct 2014 21:32:06 +0100

> The SMC91x is written to explicitly look up the IRQ resource
> from the platform device and extract the IRQ and flags, however
> the platform_get_irq() does additional things, like call
> of_irq_get() in the device tree case, which will translate
> the IRQ using the irqdomain and defer the probe if the
> IRQ host cannot be found.
> 
> As we're not looking up the resource, this will not retrieve
> the IRQ flags, but that is better done using
> irqd_get_trigger_type(), as the trigger is what the driver
> wants to modify. We take care to preserve the semantics that
> will make the trigger type provided from the resource
> override any local specifier.
> 
> Tested on the Nomadik NHK15 which has its SMC91x IRQ line
> connected to a STMPE2401 GPIO expander on I2C.
> 
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>

Applied, thanks.
