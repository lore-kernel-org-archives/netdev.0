From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec: Fix the build as module
Date: Wed, 20 Mar 2013 14:46:03 -0400 (EDT)
Message-ID: <20130320.144603.766777004936368644.davem@davemloft.net>
References: <1363803572-17039-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Frank.Li@freescale.com, u.kleine-koenig@pengutronix.de,
	netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754593Ab3CTSqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 14:46:10 -0400
In-Reply-To: <1363803572-17039-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Wed, 20 Mar 2013 15:19:32 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Since commit ff43da86c69 (NET: FEC: dynamtic check DMA desc buff type) the 
> following build error happens when CONFIG_FEC=m
> 
> ERROR: "fec_ptp_init" [drivers/net/ethernet/freescale/fec.ko] undefined!
> ERROR: "fec_ptp_ioctl" [drivers/net/ethernet/freescale/fec.ko] undefined!
> ERROR: "fec_ptp_start_cyclecounter" [drivers/net/ethernet/freescale/fec.ko] undefined!
> 
> Fix it by exporting the required fec_ptp symbols.
> 
> Reported-by: Uwe Kleine-Koenig <u.kleine-koenig@pengutronix.de>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied and queued up for -stable.
