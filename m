From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] net: phy: prevent double suspend
Date: Tue, 27 Jan 2015 00:17:17 -0800 (PST)
Message-ID: <20150127.001717.1106007866894969774.davem@davemloft.net>
References: <1422338740-18418-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de,
	b38611@freescale.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752016AbbA0IRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:17:19 -0500
In-Reply-To: <1422338740-18418-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 26 Jan 2015 22:05:36 -0800

> This patch series addresses a problem that Fugang and I observed on different
> platforms where a given PHY device might end-up being suspended twice.
> 
> Once as part of the call from ndo_open() all the way down to phy_detach() and
> phy_suspend() and a second time when the generic platform device/driver
> suspend/resume callbacks are called in drivers/net/phy/mdio_bus.c.
> 
> Thanks to Fugang for giving this a quick try on i.MX6/FEC and reporting
> positive test results!

Series applied, thanks Florian.
