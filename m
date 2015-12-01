From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: [PATCH 0/3] net: fec: Reset ethernet PHY whenever the enet_out
 clock
Date: Tue, 1 Dec 2015 08:24:50 +0100
Message-ID: <20151201082450.6a4a9421@ipc1.ka-ro>
References: <1448883168-30742-1-git-send-email-LW@KARO-electronics.de>
	<BN3PR0301MB1219D0A7525EB2535856BE52F50F0@BN3PR0301MB1219.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	Greg Ungerer <gerg@uclinux.org>,
	Kevin Hao <haokexin@gmail.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Philippe Reynes <tremyfr@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	"Stefan Agner" <stefan@agner.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Uwe Kleine-K?nig" <u.kleine-koenig@pengutronix.de>
To: Duan Andy <fugang.duan@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BN3PR0301MB1219D0A7525EB2535856BE52F50F0@BN3PR0301MB1219.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> From: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de> Sent: Monday, Nove=
mber 30, 2015 7:33 PM
> > To: Andrew Lunn; David S. Miller; Estevam Fabio-R49496; Greg Ungere=
r;
> > Kevin Hao; Lothar Wa=C3=9Fmann; Lucas Stach; Duan Fugang-B38611; Ph=
ilippe
> > Reynes; Richard Cochran; Russell King; Sascha Hauer; Stefan Agner; =
linux-
> > kernel@vger.kernel.org; netdev@vger.kernel.org; Jeff Kirsher; Uwe K=
leine-
> > K=C3=B6nig
> > Subject: [PATCH 0/3] net: fec: Reset ethernet PHY whenever the enet=
_out
> > clock
> >=20
> > This patchset fixes a regression introduced by commit 8fff755e9f8d =
("net:
> > fec: Ensure clocks are enabled while using mdio bus") for ethernet =
PHYs
> > that are using ENET_OUT as reference clock (on i.MX6 or i.MX28)
> >=20
> Do you mean commit 8fff755e9f8d cause your problem ?  This commit jus=
t manage ipg clock in runtime because mdio bus can access external phy =
switch no matter netdev status.
>=20
No. Actually I meant commit e8fcfcd5684a ("net: fec: optimize the clock=
 management to save power")
which started to disable the clocks when not in use.

Sorry for the confusion,
Lothar Wa=C3=9Fmann
