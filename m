From: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Subject: Re: [PATCH 3/3] net/macb: make clk_enable atomic
Date: Mon, 25 Mar 2013 09:33:34 +0100
Message-ID: <20130325083334.GA27739@pengutronix.de>
References: <1363973615-17863-1-git-send-email-s.trumtrar@pengutronix.de>
 <1363973615-17863-3-git-send-email-s.trumtrar@pengutronix.de>
 <CAOMZO5BRDU_-fvv4PZQcLe-4OdZ4bDQ8m+nNHEFcC1Y2+zdh9g@mail.gmail.com>
 <20130324.170849.1662647665547155225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: festevam@gmail.com, netdev@vger.kernel.org, nicolas.ferre@atmel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:41336 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756585Ab3CYIdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 04:33:40 -0400
Content-Disposition: inline
In-Reply-To: <20130324.170849.1662647665547155225.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 24, 2013 at 05:08:49PM -0400, David Miller wrote:
> From: Fabio Estevam <festevam@gmail.com>
> Date: Fri, 22 Mar 2013 14:38:39 -0300
> 
> > On Fri, Mar 22, 2013 at 2:33 PM, Steffen Trumtrar
> > <s.trumtrar@pengutronix.de> wrote:
> >> Use clk_prepare_enable to be safe on SMP systems.
> > 
> > Wouldn't you have to use clk_disable_unprepare() now?
> 
> Indeed I think he does.
> 

I will fix that of course.

Thanks,
Steffen

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
