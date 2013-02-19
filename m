From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH v2 0/5] Generic PHY Framework
Date: Tue, 19 Feb 2013 18:17:12 +0200
Message-ID: <20130219161712.GB5736@arwen.pp.htv.fi>
References: <1361253198-7401-1-git-send-email-kishon@ti.com>
 <201302191233.54677.arnd@arndb.de>
 <20130219131258.GV23197@arwen.pp.htv.fi>
 <201302191434.40495.arnd@arndb.de>
 <20130219150500.GG4390@arwen.pp.htv.fi>
 <5123A32D.4030005@pengutronix.de>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1LKvkjL3sHcu1TtY"
Cc: <balbi@ti.com>, Arnd Bergmann <arnd@arndb.de>,
	<linux-usb@vger.kernel.org>, <linux@arm.linux.org.uk>,
	<mchehab@redhat.com>, <davem@davemloft.net>, <tony@atomide.com>,
	<gregkh@linuxfoundation.org>,
	<broonie@opensource.wolfsonmicro.com>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, kishon <kishon@ti.com>,
	<eballetbo@gmail.com>, <santosh.shilimkar@ti.com>,
	<linux-arm-kernel@lists.infradead.org>, <rob@landley.net>,
	<netdev@vger.kernel.org>, <swarren@nvidia.com>,
	<javier@dowhile0.org>, <linux-omap@vger.kernel.org>,
	<akpm@linux-foundation.org>, <cesarb@cesarb.net>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5123A32D.4030005@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--1LKvkjL3sHcu1TtY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Feb 19, 2013 at 05:07:09PM +0100, Marc Kleine-Budde wrote:
> On 02/19/2013 04:05 PM, Felipe Balbi wrote:
> > Hi,
> >=20
> > On Tue, Feb 19, 2013 at 02:34:40PM +0000, Arnd Bergmann wrote:
> >> On Tuesday 19 February 2013, Felipe Balbi wrote:
> >>> On Tue, Feb 19, 2013 at 12:33:54PM +0000, Arnd Bergmann wrote:
> >>>>> Currently drivers/phy and drivers/net/phy are independent and are n=
ot=20
> >>>>> related to each other. There are some fundamental differences on ho=
w=20
> >>>>> these frameworks work. IIUC, the *net* uses bus layer (MDIO bus) to=
=20
> >>>>> match a PHY device with a PHY driver and the Ethernet device uses t=
he=20
> >>>>> bus layer to get the PHY.
> >>>>> The Generic PHY Framework however doesn't have any bus layer. The P=
HY=20
> >>>>> should be like any other Platform Devices and Drivers and the frame=
work=20
> >>>>> will provide some APIs to register with the framework. And there ar=
e=20
> >>>>> other APIs which any controller can use to get the PHY (for e.g., i=
n the=20
> >>>>> case of dt boot, it can use phandle to get a reference to the PHY).
> >>>>
> >>>> Hmm, I think the use of a bus_type for a PHY actually sounds quite
> >>>> appropriate. The actual PHY device would then be a child of the
> >>>
> >>> really ? I'm not so sure, the *bus* used by the PHY is ULPI, UTMI,
> >>> UTMI+, PIP3, I2C, etc... adding another 'fake' bus representation is a
> >>> bit overkill IMO.
> >>>
> >>> Imagine an I2C-controlled PHY driver like isp1301, that driver will h=
ave
> >>> to register i2c_driver and phy_driver, which looks weird to me. If the
> >>> only substitute for class is a bus, we can't drop classes just yet, I=
'm
> >>> afraid.
> >>>
> >>> Imagine a regulator bus, a pwm bus, an LED bus etc. They don't make
> >>> sense IMHO.
> >>
> >> It's a fine line, but I think a phy is something that resembles a devi=
ce
> >> more than an LED does. When I read patch 1, I also noticed and comment=
ed
> >> on the fact that it does use a 'class'. Now, according to Greg, we sho=
uld
> >> use 'bus_type' instead of 'class' in new code. I originally disagreed =
with
> >> that concept, but he's the boss here and it's good if he has a vision
> >> how things should be lined out.
> >>
> >> In practice, there is little difference between a 'bus_type' and a 'cl=
ass',
> >> so just replace any instance of the former with the latter in your head
> >> when reading the code ;-)
> >=20
> > it's not so simple :-) if we must use bus_type we need to introduce all
> > the device/driver matching mechanism which isn't necessary with a class.
>=20
> You have the code for phy <-> device matching in your framework anyway.
> Using the bus infrastructure brings changes the open coded matching into
> bus callbacks.

it's not the same thing. Current matching is just to figure out which
phy belongs to which user. The bus matching rules are to bind a device
with its driver, but that part has been taken care of by the underlying
control bus used by the phy, be it i2c, spi, or whatever else.

--=20
balbi

--1LKvkjL3sHcu1TtY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRI6WIAAoJEIaOsuA1yqREdDkQAJ8mDf3XwVv9HFpfn3FLjckZ
bpCeA/7sufKd+VOCk7gdvVN4tkNUAK59AxmviiaOxYDqqXPymlMiRx7d3Jex4WyP
npNVpejP2g9eNynZLGxGPy8zF27dCKPxB+uuYMg+ugQB3wM1xYFZMVAgxJ50TqYS
YTChNf8/E3xyl/GTrAE/qY4IKPSoDzq/dwvKKxJvz53oHfDoeqHdV2KMSpQ59ryX
FfCjKZRPrdMycPuzi8XqXhz6vLn8VZPih7NMdnhi27JNAuraEjgKVdPScoKdJix8
+x6oTo4FFHHnQz8CRBF+PRGkmx3lJ5OISbc9ehA8CZQKXQkc4r7WV7PuHPFtLJVV
i4jeO/zEPOXahsqQXoLLKa/gbcDwyOUIseISR9Jtk4Gp2eiCkHQNQkppb4E/kxgo
NcwjyF+1HiAvyvLZqKErASKeTN9HIThgQ9AuTFyHxskF6LjSLumYJeoF8393+Ph5
Ljj0BhgCiuJNvX/kTHd8maQ65gNTSpgSFBPbbs+PHEiUlzswFUQicehHMofrfvq0
ZIbu+TrLiM/WzxNTGHdGhTdIp2jtA+WCyZAoQO7axLXWT4ecRcVmPEuzlt7siiAs
XhcYSnCCbhIbMPNPXiixh6BaNYfuP+7tokQVNMWSj/AudJb++r0vdlCqVTDdqd9h
2Fgy0cqMpD61uqNuVqgQ
=3Fy4
-----END PGP SIGNATURE-----

--1LKvkjL3sHcu1TtY--
