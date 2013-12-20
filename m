From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: FEC performance degradation with certain packet sizes
Date: Fri, 20 Dec 2013 08:18:59 +0800
Message-ID: <20131220001858.GD7172@S2101-09.ap.freescale.net>
References: <528F50AE.3030804@digi.com>
 <201311240540.23813.marex@denx.de>
 <529310A4.70906@digi.com>
 <52B1D0C6.6010305@digi.com>
 <1387388339.19078.321.camel@edumazet-glaptop2.roam.corp.google.com>
 <0afcc48493b941ffab991d52b7c97a0d@BLUPR03MB373.namprd03.prod.outlook.com>
 <1387494299.19078.378.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	Hector Palacios <hector.palacios@digi.com>,
	Marek Vasut <marex@denx.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe005.messaging.microsoft.com ([207.46.163.28]:3708 "EHLO
	co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756318Ab3LTARw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 19:17:52 -0500
Content-Disposition: inline
In-Reply-To: <1387494299.19078.378.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 03:04:59PM -0800, Eric Dumazet wrote:
> On Thu, 2013-12-19 at 02:44 +0000, fugang.duan@freescale.com wrote:
> 
> > Enet IP don't support tso feature.
> > 
> > I will reproduce the issue in imx6q/dl sd platform, and analyze the issue.
> > Previous test, we don't use netpipe tool test ethernet performance.
> 
> drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c seems broken...

The fec driver running on IMX is drivers/net/ethernet/freescale/fec_main.c

Shawn

> 
> If tx_skb_align_workaround() returns NULL, returning NETDEV_TX_BUSY 
> is the worst possible thing to do.
> 
> Packet should be dropped instead.
> 
> Probably not related to your issue.
> 
> 
