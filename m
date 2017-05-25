From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: put genphy_config_init's EXPORT_SYMBOL
 directly after the function
Date: Thu, 25 May 2017 12:48:58 -0400 (EDT)
Message-ID: <20170525.124858.1233706826158496746.davem@davemloft.net>
References: <20170523222607.13645-1-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        kernel@pengutronix.de
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59154 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942707AbdEYQtA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:49:00 -0400
In-Reply-To: <20170523222607.13645-1-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
Date: Wed, 24 May 2017 00:26:07 +0200

> Commit af6b6967d6e1 ("net: phy: export genphy_config_init()") introduced
> this EXPORT_SYMBOL and put it after gen10g_soft_reset() instead of
> directly after genphy_config_init. Probably this happend when the patch
> was applied because http://patchwork.ozlabs.org/patch/339622/ looks ok.
> 
> Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>

Applied to net-next, thanks.
