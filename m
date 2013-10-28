From: Sebastian Reichel <sre@ring0.de>
Subject: Re: [PATCH 2/4] wl1251: move power GPIO handling into the driver
Date: Tue, 29 Oct 2013 00:26:26 +0100
Message-ID: <20131028232624.GA950@earth.universe>
References: <1382890469-25286-1-git-send-email-sre@debian.org>
 <1382890469-25286-3-git-send-email-sre@debian.org>
 <1382891056.102746625@f315.i.mail.ru>
 <20131027201218.GA4414@earth.universe>
 <CANOLnONKcC1i19ypb4rh2Rff3WsVhhuUhNvZvYwDV2-ZNtjVxQ@mail.gmail.com>
 <20131028192354.GA18208@sirena.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="uAKRQypu60I7Lcqm"
Cc: Grazvydas Ignotas <notasas@gmail.com>,
	Alexander Shiyan <shc_work@mail.ru>,
	Luciano Coelho <luca@coelho.fi>,
	Mark Rutland <mark.rutland@arm.com>,
	devicetree@vger.kernel.org, Russell King <linux@arm.linux.org.uk>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Tony Lindgren <tony@atomide.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Stephen Warren <swarren@wwwdotorg.org>,
	linux-doc@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Rob Herring <rob.herring@calxeda.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Sachin Kamat <sachin.kamat@linaro.org>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Felipe Balbi <balbi@ti.com>, Rob Landley <rob@landley.net>,
	netdev@vger.kernel.org,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
To: Mark Brown <broonie@kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131028192354.GA18208@sirena.org.uk>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, Oct 28, 2013 at 12:23:54PM -0700, Mark Brown wrote:
> On Mon, Oct 28, 2013 at 07:29:52PM +0200, Grazvydas Ignotas wrote:
>=20
> > When wl12xx family of chips is connected through SDIO, we already have
> > that pin set up as a regulator controlled with the help of mmc
> > subsystem. When time comes to communicate with the chip, mmc subsystem
> > sees this as yet another SD card and looks for associated regulator
> > for it, and the board file has that set up as a fixed regulator
> > controlling that pin (see pandora_vmmc3 in
> > arch/arm/mach-omap2/board-omap3pandora.c). To prevent poweroff after
> > first SDIO communications are over, pm_runtime calls are used in
> > drivers/net/wireless/ti/wl1251/sdio.c .
>=20
> Is this actually controlling VMMC though, or is it some other control?
> If it's not controlling VMMC then it shouldn't say that it is.
>=20
> > I don't know if something similar can be done done in SPI case, but
> > I'm sure this is not the first your-so-called regulator misuse.
>=20
> It's not the first but that doesn't make controlling something other
> than a regulator through the regulator API any less broken.

I gave it a second try to find out details for this pin:

1. The pin is named PMEN in the Nokia N900 schematics
2. PMEN is described as "Power management enable - system shutdown"
   in a crippled datasheet of the wl1253, which I found in the internet.

I don't think this is supposed to be handled by the regulator API.

-- Sebastian

--uAKRQypu60I7Lcqm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBCAAGBQJSbvKgAAoJENju1/PIO/qa9/4P/3bgI8we1v7yHBUBlbrUZ/qn
9aIlsdohRsCHxuW5eTOTIEV3zXuEczUy//fijue0OK0nMXg3OI2xk7YPyj5Lncuh
IiV1dYLfy0vQN9iMersFJJDdeR21t07jn8x9Cq+X+lA8SJsMMLIVYqaX+PyTE8+U
ERNEjWsOuTfAmOxZXysFJPWF/xJ1gN1TygZ9WfncDxD4dZlBd6PMmWYSWbvpa4nr
yOSSCuThLpQfwTYad/PqLZlwKwdS/V0zG56Lf9jyAPv2Qx7JmrSl+KvIi8aGsD03
NXnjTOv0P8EeVXy9NVwpoT50qyOVq0qE9PNkuVMqkwgk20MDrE5YpSgha8BYn9E4
Ia8RLEUCY86h4/EuxuUhDbio80HlYpjcVC72/dPWO66ZJ8BvkP9vbwm7wR04R607
vcPjlHgxCUJSVTMoszstNOrO+JBq4IO3w1VTrE3cMF0Ge17pvj+x5/mt1aYzIC3R
z2s9XCjh0AiHI1DpBUi8iBwHNRYK2EnrJNW560C5FKf70PTUwvP+K83H/2tBUn79
M762U1cxOkb8ikgoeSsmdPDf/H5tsRRbUW4/4IX8yf8VPKLAGz9u2G6XFt4JDAQO
2g2yh6MeAOq6T8DPFv3DnUEmyXK9Hn00dMs3VowgdIhmCh/Vamn1HXY5f9bnVMD6
u+xk0uvWdCm39RJFUJQD
=uEvP
-----END PGP SIGNATURE-----

--uAKRQypu60I7Lcqm--
