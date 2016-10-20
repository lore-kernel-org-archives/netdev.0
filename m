From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: drop check for clk==NULL before calling clk_*
Date: Thu, 20 Oct 2016 14:20:45 -0400 (EDT)
Message-ID: <20161020.142045.1040137290674881888.davem@davemloft.net>
References: <20161020082827.598-1-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: fugang.duan@nxp.com, kernel@pengutronix.de, netdev@vger.kernel.org
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44164 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932519AbcJTSUr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 14:20:47 -0400
In-Reply-To: <20161020082827.598-1-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
Date: Thu, 20 Oct 2016 10:28:27 +0200

> clk_prepare, clk_enable and their counterparts (at least the common clk
> ones, but also most others) do check for the clk being NULL anyhow (and
> return 0 then), so there is no gain when the caller checks, too.
> 
> Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>

Applied to net-next.
