From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
        <u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net: fec: set mac address unconditionally
Date: Thu, 22 Sep 2016 08:08:36 +0200
Message-ID: <20160922060836.h3rayf37jk3w75lm@pengutronix.de>
References: <1474464655-126940-1-git-send-email-g.schenk@eckelmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: fugang.duan@nxp.com, netdev@vger.kernel.org, kernel@pengutronix.de
To: Gavin Schenk <g.schenk@eckelmann.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:50842 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753219AbcIVGIj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 02:08:39 -0400
Content-Disposition: inline
In-Reply-To: <1474464655-126940-1-git-send-email-g.schenk@eckelmann.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

just a few nitpicks:

On Wed, Sep 21, 2016 at 03:30:55PM +0200, Gavin Schenk wrote:
> Fixes: 9638d19e4816 ("net: fec: add netif status check before set mac address")

This line belongs to in the S-o-B area below.

> If the mac address origin is not dt, you can only safe assign a

s/safe/safely/

> mac address after "link up" of the device. If the link is down the
> clocks are disabled and because of issues assigning registers when
> clocks are down the new mac address is discarded on some soc's. This fix

s/down/off/; s/is discarded/cannot be written in .ndo_set_mac_address()/

> sets the mac address unconditionally in fec_restart(...) and ensures
> consistens between fec registers and the network layer.

s/consistens/consistency/

Other than that:

Acked-by: Uwe Kleine-König <u.kleine-koenig@eckelmann.de>

Thanks
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-König            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
