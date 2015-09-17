From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v8 1/3] can: Allwinner A10/A20 CAN Controller support -
 Devicetree bindings
Date: Thu, 17 Sep 2015 12:06:17 +0200
Message-ID: <20150917100617.GB4684@lukather>
References: <1442402482-7118-1-git-send-email-info@gerhard-bertelsmann.de>
 <1442402482-7118-2-git-send-email-info@gerhard-bertelsmann.de>
 <55FA7428.4030801@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nM4qzG6nHdnn/sXd"
Cc: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>,
	wg@grandegger.com, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55FA7428.4030801@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--nM4qzG6nHdnn/sXd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 17, 2015 at 10:04:56AM +0200, Marc Kleine-Budde wrote:
> On 09/16/2015 01:21 PM, Gerhard Bertelsmann wrote:
> > Devicetree bindings for Allwinner A10/A20 CAN
> >=20
> > Signed-off-by: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
> > ---
> >=20
> >  .../devicetree/bindings/net/can/sun4i_can.txt      |  38 +
> >  1 files changed, 389 insertions(+)
> >=20
> >=20
> > diff --git a/Documentation/devicetree/bindings/net/can/sun4i_can.txt b/=
Documentation/devicetree/bindings/net/can/sun4i_can.txt
> > new file mode 100644
> > index 0000000..cd0f50c
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/can/sun4i_can.txt
> > @@ -0,0 +1,38 @@
> > +Allwinner A10/A20 CAN controller Device Tree Bindings
> > +-----------------------------------------------------
> > +
> > +Required properties:
> > +- compatible: "allwinner,sun4i-a10-can"
> > +- reg: physical base address and size of the Allwinner A10/A20 CAN reg=
ister map.
> > +- interrupts: interrupt specifier for the sole interrupt.
> > +- clock: phandle and clock specifier.
> > +
> > +
> > +Example
> > +-------
> > +
> > +SoC common .dtsi file:
> > +
> > +	can0_pins_a: can0@0 {
> > +		allwinner,pins =3D "PH20","PH21";
> > +		allwinner,function =3D "can";
> > +		allwinner,drive =3D <0>;
> > +		allwinner,pull =3D <0>;
> > +	};
> > +...
> > +	can0: can@01c2bc00 {
> > +		compatible =3D "allwinner,sun4i-a10-can";
> > +		reg =3D <0x01c2bc00 0x400>;
> > +		interrupts =3D <0 26 4>;
> > +		clocks =3D <&apb1_gates 4>;
> > +		status =3D "disabled";
> > +	};
>=20
> What about adding this snippet to SoC where the CAN core is available?
> Maxime, what's the policy on sinxi?

It would be great, but it can come as a second step.

> If you give me an Ack I'd like to take the series via linux-can-next
> (and to net-next) upstream.

I just did so for this patch, I'll review the driver when I'll have a
bit of time.

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--nM4qzG6nHdnn/sXd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV+pCZAAoJEBx+YmzsjxAg5F0P/0bQ+EG0MwVEP0RiMFFlg+Zj
odfmDTGAalQQoHUZYZ6yV2ZvluTXnKGWmKdH0xlRE2vVC4BuiLp9geJrfRhqYxQO
HFQ5rFvsslilrWdI8nIBIjRzZ5zCB5l+Zi8O6j7L/V2JeYuBJ4/GwFwloVaPMf0G
zmab+KUD4ejs+U3QMaX2rZ69XPqLnOW3+ABqkwstT3VnBAXy0BHbhl2+pEVCLghU
st02DiQmBKnr2GGFGV359H9+/UrLjSqPYoHtthXkWlijWQCGZgMYvtz3IRfYbbCr
1kvf2Jiwx+9riYkMqtsZPJc1Ue8unlAxo6YiDNpq1ZQOHw6ZS06cPwMJ1NQaDL4A
NF4I9nuORlhm4pZs5g1fK5UxCE2oDJluRQvIPfW+mhmPN3ght7Vbnh4JpS0p1cNy
G323Wg+lSATQLYrPS0tYSqoR7QZZoGIiiRu4KRyI7kUAkgpBoJbXz3UHGhOOPH/n
29NLGLgngegx+H7a2FlGwzDjqD2gK4eiZDF4D1kiPBt+tyJ0wovUAFiZ2P1+TeqB
J8271uDNPZp0ri8CDEB6VV7c07OzIxq8X//DkvXOkkZbpwdprWEkq7YskzL59Rim
O0Ya21A3u6/F4XalKSgfa0uWtIzmSZLp5Zuss4u6QpaUMmCXPm9sUE7rohHOfiPs
DXJhDwvf1CXw7n91WZpC
=2pKe
-----END PGP SIGNATURE-----

--nM4qzG6nHdnn/sXd--
