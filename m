From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 05/12] Add dummy smsc911x regulators to cm-t35.
Date: Tue, 3 Apr 2012 10:26:12 -0700
Message-ID: <20120403172611.GD8240@atomide.com>
References: <1332494504-10251-1-git-send-email-Russ.Dill@ti.com>
 <1332494504-10251-6-git-send-email-Russ.Dill@ti.com>
 <4F71E290.2050403@compulab.co.il>
 <20120327172819.GQ9859@atomide.com>
 <4F72B0D0.70703@compulab.co.il>
 <20120328170316.GR9859@atomide.com>
 <4F75CFD8.7050809@compulab.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russ Dill <Russ.Dill@ti.com>, linux-omap@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Matt Porter <mporter@ti.com>, robert.marklund@stericsson.com,
	linus.walleij@linaro.org,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Igor Grinberg <grinberg@compulab.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-01-ewr.mailhop.org ([204.13.248.71]:36446 "EHLO
	mho-01-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754715Ab2DCR0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 13:26:18 -0400
Content-Disposition: inline
In-Reply-To: <4F75CFD8.7050809@compulab.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Igor Grinberg <grinberg@compulab.co.il> [120330 08:26]:
> On 03/28/12 19:03, Tony Lindgren wrote:
> > 
> > ..care to see if you have OMAP_GPIO_IRQ entry for your board? If so, we're
> > still waiting for the cleanup-fixes branch to get merged that changes
> > things to use gpio_to_irq() instead.
> 
> Nope, no OMAP_GPIO_IRQ in the board code.
> Also, the GPIO -> IRQ mapping for the smsc911x is done in gpmc-smsc911x.c
> and it uses gpio_to_irq() already.

OK, maybe it's caused by spurious interrupts? Have you
checked the GPIO interrupt edge/level setup is correct?

Regards,

Tony
