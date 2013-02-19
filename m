From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH v2 0/5] Generic PHY Framework
Date: Tue, 19 Feb 2013 17:05:00 +0200
Message-ID: <20130219150500.GG4390@arwen.pp.htv.fi>
References: <1361253198-7401-1-git-send-email-kishon@ti.com>
 <201302191233.54677.arnd@arndb.de>
 <20130219131258.GV23197@arwen.pp.htv.fi>
 <201302191434.40495.arnd@arndb.de>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="64j1qyTOoGvYcHb1"
Cc: <balbi@ti.com>, kishon <kishon@ti.com>, <rob@landley.net>,
	<tony@atomide.com>, <linux@arm.linux.org.uk>,
	<eballetbo@gmail.com>, <javier@dowhile0.org>,
	<gregkh@linuxfoundation.org>, <akpm@linux-foundation.org>,
	<mchehab@redhat.com>, <cesarb@cesarb.net>, <davem@davemloft.net>,
	<santosh.shilimkar@ti.com>, <broonie@opensource.wolfsonmicro.com>,
	<swarren@nvidia.com>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201302191434.40495.arnd@arndb.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--64j1qyTOoGvYcHb1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Feb 19, 2013 at 02:34:40PM +0000, Arnd Bergmann wrote:
> On Tuesday 19 February 2013, Felipe Balbi wrote:
> > On Tue, Feb 19, 2013 at 12:33:54PM +0000, Arnd Bergmann wrote:
> > > > Currently drivers/phy and drivers/net/phy are independent and are n=
ot=20
> > > > related to each other. There are some fundamental differences on ho=
w=20
> > > > these frameworks work. IIUC, the *net* uses bus layer (MDIO bus) to=
=20
> > > > match a PHY device with a PHY driver and the Ethernet device uses t=
he=20
> > > > bus layer to get the PHY.
> > > > The Generic PHY Framework however doesn't have any bus layer. The P=
HY=20
> > > > should be like any other Platform Devices and Drivers and the frame=
work=20
> > > > will provide some APIs to register with the framework. And there ar=
e=20
> > > > other APIs which any controller can use to get the PHY (for e.g., i=
n the=20
> > > > case of dt boot, it can use phandle to get a reference to the PHY).
> > >=20
> > > Hmm, I think the use of a bus_type for a PHY actually sounds quite
> > > appropriate. The actual PHY device would then be a child of the
> >=20
> > really ? I'm not so sure, the *bus* used by the PHY is ULPI, UTMI,
> > UTMI+, PIP3, I2C, etc... adding another 'fake' bus representation is a
> > bit overkill IMO.
> >=20
> > Imagine an I2C-controlled PHY driver like isp1301, that driver will have
> > to register i2c_driver and phy_driver, which looks weird to me. If the
> > only substitute for class is a bus, we can't drop classes just yet, I'm
> > afraid.
> >=20
> > Imagine a regulator bus, a pwm bus, an LED bus etc. They don't make
> > sense IMHO.
>=20
> It's a fine line, but I think a phy is something that resembles a device
> more than an LED does. When I read patch 1, I also noticed and commented
> on the fact that it does use a 'class'. Now, according to Greg, we should
> use 'bus_type' instead of 'class' in new code. I originally disagreed with
> that concept, but he's the boss here and it's good if he has a vision
> how things should be lined out.
>=20
> In practice, there is little difference between a 'bus_type' and a 'class=
',
> so just replace any instance of the former with the latter in your head
> when reading the code ;-)

it's not so simple :-) if we must use bus_type we need to introduce all
the device/driver matching mechanism which isn't necessary with a class.

> I understand that there is not a real common bus here, and the bus_type
> infrastructure would basically be used as a way to represent each PHY
> in sysfs and provide a way to enumerate and look them up inside of the
> kernel.

right, but maybe we need another mechanism. If, in the long run we must
use bus_type, then eventually pwm, led, regulators, etc will all be
converted to bus_type. It will look quite weird IMHO.

Greg, can you pitch your suggestion here ? It would be great to hear
your rationale behind dropping class infrastructure, couldn't find
anything through Google and since feature-removal-schedule.txt has been
removed (without adding it to feature-removal-schedule.txt, I must add
:-) I don't know what's the idea behind removing classes.

cheers

--=20
balbi

--64j1qyTOoGvYcHb1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRI5SbAAoJEIaOsuA1yqREUfYP/1Va53JVZFSDnDRA4yV6Cq5a
ldTluhlGuUhVni0Cyovis5LweKvPHhPcmb1kGUCwW2avtwJLg2FBySj5v+uKqjWy
vSeDS9ceFHYp03JAQbyYH7aRj5kDGUVHK32SanTWYDEMH3T4TSmqfUjB10dikOU/
dEhbu957T/pu21VSSgF+f0kYFCBS5EEbp0dzO4NpgPBt4TMP2Z11kXqOE9yGYWqy
zV+SNpektQ4Rj74NA14UuzylpPhqNSpVpEXTasTGtnAcunIrUQPOIu1PB1ZjKnR9
v1maWqbpZP8+iMHLZuL6+zTyEvEa+GE8d1E76IZapcVYwfwiOElloOXX1vnZ6ylu
t2Uhp1TIGzRCE8P5o45aK1Zueb0q2SZpG4jCSPpzt16MCV+YydXbXI3JtRNfzGcw
tDKA0CT/5/97YetsG1qEdc00CIMrNFnp7nrX8I0JtAu22qE141TuHCcyXSEqYOaY
ysKdi5CDVmbduJrkYOUkHy3b6rQExJZhFAcBLAjWN6q1winX1bF4ZWD6slu2CwgK
HVHvfr2iLDsJPVPZNiCIhaLnRJYOEX3twYfFoaDJQbTirqBHxXczlKIWBTePu/0l
xexrzWYlyZ/J9Z71XV2nOFYIavzNEz74uImSrgxNJL5Q1w33Utakgwd3p2ggEMUA
9YJockzXn1o8js8fP4pp
=ImRF
-----END PGP SIGNATURE-----

--64j1qyTOoGvYcHb1--
