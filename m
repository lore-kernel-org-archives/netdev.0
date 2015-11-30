From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: fec: fix enet_out clock handling
Date: Mon, 30 Nov 2015 02:58:23 +0100
Message-ID: <20151130015823.GA32662@lunn.ch>
References: <1448631550-943-1-git-send-email-LW@KARO-electronics.de>
 <BN3PR0301MB1219C4D8E1B09F1AE27E18FAF5020@BN3PR0301MB1219.namprd03.prod.outlook.com>
 <20151128164337.GF32356@lunn.ch>
 <BN3PR0301MB12193BED335F9781168308CCF5000@BN3PR0301MB1219.namprd03.prod.outlook.com>
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
In-Reply-To: <BN3PR0301MB12193BED335F9781168308CCF5000@BN3PR0301MB1219.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Do you mean PHY switch also use the enet_out clock ?

Yes, the Marvell switches i've have connected to a Vybrid use enet_out
clock. There was a recent change to IMX pinctrl which broke the muxing
for ENET_OUT on Vydrid, which broke the probing of these switches. It
was no longer possible to mux the pin as ENET_OUT, and the switches
disappeared.

	Andrew
