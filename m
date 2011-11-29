From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 v5] net/smsc911x: Add regulator support
Date: Tue, 29 Nov 2011 18:37:29 -0500 (EST)
Message-ID: <20111129.183729.968318782117791817.davem@davemloft.net>
References: <1322132587-2049-1-git-send-email-robert.marklund@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com,
	mathieu.poirier@linaro.org, lethal@linux-sh.org,
	linux-sh@vger.kernel.org, s.hauer@pengutronix.de, tony@atomide.com,
	linux-omap@vger.kernel.org, vapier@gentoo.org,
	uclinux-dist-devel@blackfin.uclinux.org, linus.walleij@linaro.org
To: robert.marklund@stericsson.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1322132587-2049-1-git-send-email-robert.marklund@stericsson.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Marklund <robert.marklund@stericsson.com>
Date: Thu, 24 Nov 2011 12:03:07 +0100

> Add some basic regulator support for the power pins, as needed
> by the ST-Ericsson Snowball platform that powers up the SMSC911
> chip using an external regulator.
> 
> Platforms that use regulators and the smsc911x and have no defined
> regulator for the smsc911x and claim complete regulator
> constraints with no dummy regulators will need to provide it, for
> example using a fixed voltage regulator. It appears that this may
> affect (apart from Ux500 Snowball) possibly these archs/machines
> that from some grep:s appear to define both CONFIG_SMSC911X and
> CONFIG_REGULATOR:
> 
> - ARM Freescale mx3 and OMAP 2 plus, Raumfeld machines
> - Blackfin
> - Super-H
> 
> Cc: Paul Mundt <lethal@linux-sh.org>
> Cc: linux-sh@vger.kernel.org
> Cc: Sascha Hauer <s.hauer@pengutronix.de>
> Cc: Tony Lindgren <tony@atomide.com>
> Cc: linux-omap@vger.kernel.org
> Cc: Mike Frysinger <vapier@gentoo.org>
> Cc: uclinux-dist-devel@blackfin.uclinux.org
> Reviewed-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
> Signed-off-by: Robert Marklund <robert.marklund@stericsson.com>
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>

Applied, thanks.
