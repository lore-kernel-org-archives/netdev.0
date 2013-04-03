From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH v5 2/6] usb: phy: omap-usb2: use the new generic PHY
 framework
Date: Wed, 3 Apr 2013 18:48:07 +0300
Message-ID: <20130403154807.GE19093@arwen.pp.htv.fi>
References: <1364993634-6378-1-git-send-email-kishon@ti.com>
 <1364993634-6378-3-git-send-email-kishon@ti.com>
 <20130403134827.GF14680@arwen.pp.htv.fi>
 <201304031455.47864.arnd@arndb.de>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xA/XKXTdy9G3iaIz"
Cc: <balbi@ti.com>, Kishon Vijay Abraham I <kishon@ti.com>,
	<gregkh@linuxfoundation.org>, <akpm@linux-foundation.org>,
	<swarren@wwwdotorg.org>, <sylvester.nawrocki@gmail.com>,
	<rob@landley.net>, <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<cesarb@cesarb.net>, <linux-usb@vger.kernel.org>,
	<linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<tony@atomide.com>, <grant.likely@secretlab.ca>,
	<rob.herring@calxeda.com>, <b-cousson@ti.com>,
	<linux@arm.linux.org.uk>, <eballetbo@gmail.com>,
	<javier@dowhile0.org>, <mchehab@redhat.com>,
	<santosh.shilimkar@ti.com>, <broonie@opensource.wolfsonmicro.com>,
	<swarren@nvidia.com>, <linux-doc@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201304031455.47864.arnd@arndb.de>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--xA/XKXTdy9G3iaIz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Apr 03, 2013 at 02:55:47PM +0000, Arnd Bergmann wrote:
> On Wednesday 03 April 2013, Felipe Balbi wrote:
> > const ? Maybe provide a:
> >=20
> > #define DEFINE_PHY_OPS(name)    \
> > const struct phy_ops #name_phy_ops =3D {
> >=20
> > macro ? This will force people to add the const keyword :-)
>=20
> Forcing people to use const structures is good, but I think it would be
> better without the macro, just by marking the argument in=20
> devm_phy_create() as const.

that won't force the definition of the struct to be const, however. But
I get your point.

--=20
balbi

--xA/XKXTdy9G3iaIz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRXE83AAoJEIaOsuA1yqREQ+sQAKeGj69voh941wu/KTn7tFb4
D0RrvEHfbTUhaNkpsTUfurdzKk3k3GuH59HvfK9zoei36ogCIlSCwZKWWs4I9Yii
IBpXzJp9n0fZUWLMdOrJgf/JOhouLuRJ1d5u5UTeAmRBtQT3dq89EEG1sixJCNBA
QBGTW0bNdXAE2oglFG7EH2HMGeTxSJM49v2z+Lusv1bbbog8qjAOz+pL0WHBttzi
h8wKxp8yOzrmCQ4ktsiin68JFV1AuaLS+BVdbxbtgKVdDDaJ7lvqfRHnmnBSOy27
23Z2Vl36Gv299sZOiNEaYFI9z0ubNJc5N4YCVefGHPkn0+6Y/BeMrk8tXAnUnZq2
HeCtlCLxtp7HmrvRt48paDOheQc7jcamPcMktIm5QhAD1uzRwVtk34XVMY1AEWKF
TK3u7YJiy3THqXlvUvrYz+sPrpBFUEDK15Rcn/Cmk8H0gqpBtdCBU0HWHqeK//Jb
vmpvmXzpWwPPWUYWDqumf3YyAonYz/oDCmaJR/mbuIMKK5A4IIcHiqGoU11j4BUI
JU0yPf0n9BE8KEcZXKJy3LdRr6MOgSF3XZOZl4425pucdLnZNUJ1ILGHM7/6wkCx
ILTlo6mtHSU3RE5do6JCw2EwqnK5lAAsrRUGtpuIQOclt2h4npWpYe+s3XR4fxz0
xiUXWZKeY3w7HHLXlToJ
=xgLX
-----END PGP SIGNATURE-----

--xA/XKXTdy9G3iaIz--
