From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/smsc911x: fix irq resource allocation failure
Date: Mon, 04 May 2015 15:11:23 -0400 (EDT)
Message-ID: <20150504.151123.189020826693529469.davem@davemloft.net>
References: <1430730589-17378-1-git-send-email-kamlakant.patel@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
	linus.walleij@linaro.org
To: kamlakant.patel@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbbEDTLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 15:11:25 -0400
In-Reply-To: <1430730589-17378-1-git-send-email-kamlakant.patel@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <kamlakant.patel@broadcom.com>
Date: Mon, 4 May 2015 14:39:49 +0530

> From: Kamlakant Patel <kamlakant.patel@broadcom.com>
> 
> When smsc911x uses GPIO as the interrupt controller, and if both are
> loaded as modules, we get following error:
> 
> "smsc911x: Could not allocate irq resource"
> 
> This issue is because of smsc911x using platform_get_resource to get
> device tree based irq resource.
> 
> commit "9ec36ca (of/irq: do irq resolution in platform_get_irq)" and
> commit "7085a7 (drivers: platform: parse IRQ flags from resources)" add
> support in platform_get_irq to resolve irq and irq_flags respectively
> for both modern device tree and legacy static platform data platforms.
> 
> Modify smsc911x driver to use platform_get_irq to pick up irq resource
> correctly and use irq_get_trigger_type to get the IRQ trigger flags.
> 
> Signed-off-by: Kamlakant Patel <kamlakant.patel@broadcom.com>

Applied.
