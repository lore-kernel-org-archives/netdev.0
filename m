From: Duan Andy <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec: fix enet_out clock handling
Date: Mon, 30 Nov 2015 01:46:29 +0000
Message-ID: <BN3PR0301MB12193BED335F9781168308CCF5000@BN3PR0301MB1219.namprd03.prod.outlook.com>
References: <1448631550-943-1-git-send-email-LW@KARO-electronics.de>
 <BN3PR0301MB1219C4D8E1B09F1AE27E18FAF5020@BN3PR0301MB1219.namprd03.prod.outlook.com>
 <20151128164337.GF32356@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Lothar Wa?mann <LW@KARO-electronics.de>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	Kevin Hao <haokexin@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Philippe Reynes <tremyfr@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	"Uwe Kleine-K?nig" <u.kleine-koenig@pengutronix.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stefan Agner <stefan@agner.ch>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0112.outbound.protection.outlook.com ([65.55.169.112]:11763
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752751AbbK3CSq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 21:18:46 -0500
In-Reply-To: <20151128164337.GF32356@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch> Sent: Sunday, November 29, 2015 12:44 AM
> To: Duan Fugang-B38611
> Cc: Lothar Wa?mann; David S. Miller; Estevam Fabio-R49496; Kevin Hao;
> Lucas Stach; Philippe Reynes; Russell King; Uwe Kleine-K?nig; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org; Stefan Agner
> Subject: Re: [PATCH] net: fec: fix enet_out clock handling
> 
> > When MAC is not ready with clocks disabled, it is not necessary to
> > supply clock for PHY. In fact, PHY also is not ready, why does it need
> > clock ?
> 
> How about the case of the "PHY" is actually a switch? You can use the
> MDIO bus separate from the MAC, you can configure the switch while the
> MAC is down, etc. Packets can be flowing in and out of switch ports,
> while the MAC is down. You only need the MAC up when the host wants to
> send packets.
> 
>      Andrew

Do you mean PHY switch also use the enet_out clock ?
- If not, this topic is not related to the patch.
- If so, we should add flag check, we can disable the enet_out clock when the phy is not switch or switch phy doesn't use the clock in real case, which can save power.  And the patch title is not right, not "fix" since it is not a issue, just different usage for different cases.

Regards,
Andy
