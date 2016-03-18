From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Fri, 18 Mar 2016 21:11:53 +0100
Message-ID: <20160318201153.GR4292@pengutronix.de>
References: <56E99727.9040702@laposte.net>
 <20160318125455.GN4292@pengutronix.de>
 <56EC2525.8000706@laposte.net>
 <20160318191242.GQ4292@pengutronix.de>
 <56EC5788.3030509@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sebastian Frias <sf84@laposte.net>,
	Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Mason <slash.tmp@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56EC5788.3030509@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Fri, Mar 18, 2016 at 08:31:20PM +0100, Mason wrote:
> On 18/03/2016 20:12, Uwe Kleine-K=F6nig wrote:
>=20
> > On Fri, Mar 18, 2016 at 04:56:21PM +0100, Sebastian Frias wrote:
> >=20
> >> What would you think of making at803x_link_change_notify() print a
> >> message every time it should do a reset but does not has a way to =
do it?
> >=20
> > Then this question is obsolete because the device doesn't probe.
>=20
> I don't understand this statement.
>=20
> What does it mean for a question to be obsolete?

If the driver doesn't probe because it cannot control the reset line,
you don't need to think about how it should behave in
at803x_link_change_notify without control of the reset line, because
this code isn't reached then.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
