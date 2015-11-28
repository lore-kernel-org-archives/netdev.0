From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: fec: fix enet_out clock handling
Date: Sat, 28 Nov 2015 17:43:37 +0100
Message-ID: <20151128164337.GF32356@lunn.ch>
References: <1448631550-943-1-git-send-email-LW@KARO-electronics.de>
 <BN3PR0301MB1219C4D8E1B09F1AE27E18FAF5020@BN3PR0301MB1219.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lothar Wa?mann <LW@KARO-electronics.de>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	Kevin Hao <haokexin@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Philippe Reynes <tremyfr@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Uwe Kleine-K?nig <u.kleine-koenig@pengutronix.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stefan Agner <stefan@agner.ch>
To: Duan Andy <fugang.duan@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BN3PR0301MB1219C4D8E1B09F1AE27E18FAF5020@BN3PR0301MB1219.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> When MAC is not ready with clocks disabled, it is not necessary to
> supply clock for PHY. In fact, PHY also is not ready, why does it
> need clock ?

How about the case of the "PHY" is actually a switch? You can use the
MDIO bus separate from the MAC, you can configure the switch while the
MAC is down, etc. Packets can be flowing in and out of switch ports,
while the MAC is down. You only need the MAC up when the host wants to
send packets.

     Andrew
