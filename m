From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v6 1/3] can: Allwinner A10/A20 CAN Controller support -
 Devicetree bindings
Date: Mon, 14 Sep 2015 15:30:22 +0200
Message-ID: <20150914133022.GB4684@lukather>
References: <1442235299-5885-1-git-send-email-info@gerhard-bertelsmann.de>
 <1442235299-5885-2-git-send-email-info@gerhard-bertelsmann.de>
 <55F6C46D.7090203@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="H1spWtNR+x+ondvy"
Cc: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>,
	wg@grandegger.com, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55F6C46D.7090203@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--H1spWtNR+x+ondvy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, Sep 14, 2015 at 02:58:21PM +0200, Marc Kleine-Budde wrote:
> On 09/14/2015 02:54 PM, Gerhard Bertelsmann wrote:
> > Signed-off-by: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
> > ---
> >=20
> >  .../devicetree/bindings/net/can/sun4i_can.txt      |  37 +
> >  1 files changed, 37 insertions(+)
> >=20
> >=20
> > diff --git a/Documentation/devicetree/bindings/net/can/sun4i_can.txt b/=
Documentation/devicetree/bindings/net/can/sun4i_can.txt
> > new file mode 100644
> > index 0000000..b572e2b
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/can/sun4i_can.txt
> > @@ -0,0 +1,37 @@
> > +Allwinner A10/A20 CAN controller Device Tree Bindings
> > +-----------------------------------------------------
> > +
> > +Required properties:
> > +- compatible: "allwinner,sunxican"
> > +- reg: physical base address and size of the Allwinner A10/A20 CAN reg=
ister map.
> > +- interrupts: interrupt specifier for the sole interrupt.
> > +- clock: phandle and clock specifier.
> > +
> > +Example
> > +-------
> > +
> > +SoC common .dtsi file:
> > +
> > +	can0_pins_a: can0 <at> 0 {
>=20
> That's supposed to be a proper "@":
>=20
>     can0@0
>=20
> > +		allwinner,pins =3D "PH20","PH21";
> > +		allwinner,function =3D "can";
> > +		allwinner,drive =3D <0>;
> > +		allwinner,pull =3D <0>;
> > +	};
> > +
> > +	can0: can <at> 01c2bc00 {
>=20
>     can0@01c2bc00

Actually, beside '<at>' vs '@', he was right.

The name of the node in the DT should be:

<device class>@<address>

Which in our case is can@01c2bc00, like he used.

>=20
> > +		compatible =3D "allwinner,sunxican";

However, the compatible is still not right.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--H1spWtNR+x+ondvy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV9svuAAoJEBx+YmzsjxAgfoUQALyT0N96RVA5UMy1phiuRz6n
VuTdVSZHgxOs8Gl1T13nnIt7k0CgAiweaSmQqAisNeO4LVqRquEesi6pcr2zQLiX
F3e1Z5FB6U6KLndz+qsWwAwMbzKLGfThIpjpnLv2PefWhzhl5jR6Uaa+MWHkN3x4
dCBddS8AvM28lZdyQA2b50BaiSH+ZCd9I3f5dEv3U9pBC1NPTF7tXOwFHOGaXCjR
jZUViLVW9JopFCKv9+mwwmJnC7kjnHBk67MRFXLyqiUanJleYD5DUlGgzFUT0oI0
aI/5v3UdJNtvsZIAf+xAMC+kHdv9bD1p7fKRyh2z00aY17wX+AY/dr/6bEK7Caeh
/O3bStHkBic+LKVhWcwWUjK0/MkHcqaP2NYK6tlXBwLS45dk9cvRNP1S9T/4Y+2J
Wqx5ok05WPbhbyqZhdZ7DDms1GkxO9HgIIKSQ/n9+nDBMFauSoiRTUQ3HblfaRvT
mxrY5/JmIlzeN/1O9zNZG3c3gw5En5m0giOXY8JKosV1p3fGqyqbrUuzgzesjlEY
87jvNzz6ZoC2v2bbCxUxTlChWeVidXBkPX21MizvBbqrB0GRr/lpzb+OHyeZPZH+
uJY8MMnZhgo7kZeaSQnjqZzLLwB+3Cf77630oxx80lAcI+z+FZOpTwUQsj9k2/iN
jxcGJOoTp/Az6lT5uJkT
=Cbtr
-----END PGP SIGNATURE-----

--H1spWtNR+x+ondvy--
