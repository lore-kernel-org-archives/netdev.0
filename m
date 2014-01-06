From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [BUG] v3.13-rc7: freescale fec_main bugs on boot
Date: Mon, 6 Jan 2014 10:28:50 +0800
Message-ID: <20140106022847.GB26128@S2101-09.ap.freescale.net>
References: <20140105170448.GC27432@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Sascha Hauer <kernel@pengutronix.de>,
	Philipp Zabel <p.zabel@pengutronix.de>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	<devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0189.outbound.messaging.microsoft.com ([213.199.154.189]:35198
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752151AbaAFC2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 21:28:13 -0500
Content-Disposition: inline
In-Reply-To: <20140105170448.GC27432@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 05, 2014 at 05:04:48PM +0000, Russell King - ARM Linux wrote:
> Second thing is this which was introduced by 7a399e3a2e05 between rc6
> and rc7:
> 
> +       if (flags & OF_GPIO_ACTIVE_LOW)
> +               port = GPIOF_OUT_INIT_LOW;
> +       else
> +               port = GPIOF_OUT_INIT_HIGH;
> 
> -       gpio_set_value(phy_reset, 1);
> +       gpio_set_value(phy_reset, !port);

Fabio just sent a patch to revert it, and David has queued it.  Sorry
for that I did not catch it.

Shawn
