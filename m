From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: fec: Do a sanity check on the gpio number
Date: Tue, 19 Feb 2013 00:53:50 -0500 (EST)
Message-ID: <20130219.005350.884548712379647615.davem@davemloft.net>
References: <1361218831-17336-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, marex@denx.de, s.hauer@pengutronix.de,
	netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756698Ab3BSFxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 00:53:51 -0500
In-Reply-To: <1361218831-17336-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Mon, 18 Feb 2013 17:20:31 -0300

> Check whether the phy-reset GPIO is valid, prior to requesting it.
> 
> In the case a board does not provide a phy-reset GPIO, just returns immediately.
> 
> With such gpio validation in place, it is also safe to change from pr_debug to 
> dev_err in the case the gpio request fails.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
