From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Adjust ENET MDIO timeouts
Date: Tue, 27 Dec 2011 13:13:44 -0500 (EST)
Message-ID: <20111227.131344.1087161640480826569.davem@davemloft.net>
References: <1324997198-2241-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shawn.guo@freescale.com,
	kernel@pengutronix.de, rogerio.pimentel@freescale.com,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754662Ab1L0SOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 13:14:54 -0500
In-Reply-To: <1324997198-2241-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Tue, 27 Dec 2011 12:46:38 -0200

> -#define FEC_MII_TIMEOUT		1000 /* us */
> +#define FEC_MII_TIMEOUT		30 /* ms */

I don't see why you must use msecs_to_jiffies(), why not just change
FEC_MII_TIMEOUT to 30000?

That's a one-line, easy to validate, change.

Whereas if you also change the units of the timeout I have to go
through the entire driver to audit your patch, making sure none of the
FEC_MII_TIMEOUT uses in the driver have been missed.

When you make multiple changes at once, it leads to more work for the
patch reviewer, please avoid this whenever possible.

Thanks.
