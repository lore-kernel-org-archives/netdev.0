From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v7 02/10] arm: dts: sunxi: Restore EMAC changes
Date: Thu, 19 Oct 2017 08:57:46 +0200
Message-ID: <20171019065745.pzurfghdvfnpxeuc@flea.lan>
References: <20171018114458.17891-1-clabbe.montjoie@gmail.com>
 <20171018114458.17891-3-clabbe.montjoie@gmail.com>
 <20171018164450.GE15371@lunn.ch>
 <20171018185049.GA24584@Red>
Reply-To: maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uku2j2u53sbdnskz"
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
	will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDSJBYGBRIMBB3EZUHHQKGQEA7RDERQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20171018185049.GA24584@Red>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org


--uku2j2u53sbdnskz
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 18, 2017 at 08:50:49PM +0200, Corentin Labbe wrote:
> On Wed, Oct 18, 2017 at 06:44:50PM +0200, Andrew Lunn wrote:
> > On Wed, Oct 18, 2017 at 01:44:50PM +0200, Corentin Labbe wrote:
> > > The original dwmac-sun8i DT bindings have some issue on how to handle
> > > integrated PHY and was reverted in last RC of 4.13.
> > > But now we have a solution so we need to get back that was reverted.
> > >=20
> > > This patch restore arm DT about dwmac-sun8i
> > > This reverts commit fe45174b72ae ("arm: dts: sunxi: Revert EMAC chang=
es")
> > >=20
> > > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > > ---
> > >  arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts |  9 ++++++++
> > >  arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts   | 19 +++++++++++++=
++++
> > >  arch/arm/boot/dts/sun8i-h3-nanopi-m1-plus.dts     | 19 +++++++++++++=
++++
> > >  arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts         |  7 ++++++
> > >  arch/arm/boot/dts/sun8i-h3-orangepi-2.dts         |  8 +++++++
> > >  arch/arm/boot/dts/sun8i-h3-orangepi-one.dts       |  8 +++++++
> > >  arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts   |  5 +++++
> > >  arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts        |  8 +++++++
> > >  arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts      | 22 +++++++++++++=
++++++
> > >  arch/arm/boot/dts/sun8i-h3-orangepi-plus2e.dts    | 16 +++++++++++++=
+
> > >  arch/arm/boot/dts/sunxi-h3-h5.dtsi                | 26 +++++++++++++=
++++++++++
> > >  11 files changed, 147 insertions(+)
> > >=20
> > > diff --git a/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts b/arch=
/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
> > > index b1502df7b509..6713d0f2b3f4 100644
> > > --- a/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
> > > +++ b/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
> > > @@ -56,6 +56,8 @@
> > > =20
> > >  	aliases {
> > >  		serial0 =3D &uart0;
> > > +		/* ethernet0 is the H3 emac, defined in sun8i-h3.dtsi */
> > > +		ethernet0 =3D &emac;
> > >  		ethernet1 =3D &xr819;
> > >  	};
> > > =20
> > > @@ -102,6 +104,13 @@
> > >  	status =3D "okay";
> > >  };
> > > =20
> > > +&emac {
> > > +	phy-handle =3D <&int_mii_phy>;
> > > +	phy-mode =3D "mii";
> > > +	allwinner,leds-active-low;
> > > +	status =3D "okay";
> > > +};
> > > +
> > >  &mmc0 {
> > >  	pinctrl-names =3D "default";
> > >  	pinctrl-0 =3D <&mmc0_pins_a>;
> > > diff --git a/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts b/arch/a=
rm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
> > > index e1dba9ffa94b..f2292deaa590 100644
> > > --- a/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
> > > +++ b/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
> > > @@ -52,6 +52,7 @@
> > >  	compatible =3D "sinovoip,bpi-m2-plus", "allwinner,sun8i-h3";
> > > =20
> > >  	aliases {
> > > +		ethernet0 =3D &emac;
> > >  		serial0 =3D &uart0;
> > >  		serial1 =3D &uart1;
> > >  	};
> > > @@ -111,6 +112,24 @@
> > >  	status =3D "okay";
> > >  };
> > > =20
> > > +&emac {
> > > +	pinctrl-names =3D "default";
> > > +	pinctrl-0 =3D <&emac_rgmii_pins>;
> > > +	phy-supply =3D <&reg_gmac_3v3>;
> > > +	phy-handle =3D <&ext_rgmii_phy>;
> > > +	phy-mode =3D "rgmii";
> > > +
> > > +	allwinner,leds-active-low;
> > > +	status =3D "okay";
> > > +};
> > > +
> >=20
> >=20
> > > +&external_mdio {
> > > +	ext_rgmii_phy: ethernet-phy@1 {
> > > +		compatible =3D "ethernet-phy-ieee802.3-c22";
> > > +		reg =3D <0>;
> > > +	};
> > > +};
> > > +
> >=20
> > Hi Corentin
> >=20
> > I'm wondering about the order of the patches. Does the external_mdio
> > node actually exist at this point? Or only later when other patches
> > are applied?
> >=20
>=20
> You are right order of patch are wrong, I need to cut this one in two.
> "Revert=C2=B2" sunxi-h3-h5.dtsi
> apply mdiomux
> "Revert=C2=B2" all board nodes

I'm not even sure why you're actually adding them that way. Can't you
just create the new binding file, support it in the driver, and add
the matching DT nodes ?

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.

--uku2j2u53sbdnskz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZ6EzpAAoJEBx+YmzsjxAgytgP/1KB1p5cfdrLxWEVJrDcNKY3
rDUarR5FW8KDKx6sVF+7lhQy1ymawbixa7Uj7t54TUQE13UvvVsfrab96rt4wIda
QOpppy0pPEV7kkU1zrSbhMSALBVwsVmX+ONKoDS0EKfj2rqbE6QBwNbj4VFVjEMv
x3m+/oqKydq5cocN8YPzdsyCDr9QlfIymtD6c35hOjeyrGSulvUZWQke9wqj1oIc
pZ8byA19fUxU+D/A0tPB2H7Q+huFjzQu3g0qiBm1G28lR4rke1lE0wenCPPfyNQr
jXknXj3F5LuYxk3BXXZhl35sxObNYTIu7+RJBwQf076ZpJspt55RlzSxzt2sdUAf
BvsG5zLo6Mo8whwdjXQIe+lfiomRANJW/SGRf9029bpGZinPQ8DlCIihK6vdoKAm
RcD2gHptAhQ7YBzpBqiIsLqiUBwNFcQzrKu2AdbjjqTGJFVFJWoJABvLkNbpnYvE
K4w1RBssr8x/XjfsgLlL9ViGT4VYBjJVYJgzmnSLbpf3dQ3I+SwEHzgb5lrnVz0z
EGg8vKJS7EWuiCvZ/KUhCukQghS3SevrYnpft9N7+iTrWPqNjhVG8RS2+GXa4EXl
Ir4mpxddKPHuIe8SD6VN3IMnoTzHS743ZBPcIEO4NbQbwq7h8LMmxlUltwCYvxio
xCvpDsj5iDGNFM1XJ9l0
=CKnu
-----END PGP SIGNATURE-----

--uku2j2u53sbdnskz--
