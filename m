From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v4 04/10] ARM: dts: sun8i-h3: Add dt node for the syscon
 control module
Date: Tue, 11 Oct 2016 11:39:35 +0200
Message-ID: <20161011093935.GR3462@lukather>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
 <1475828757-926-5-git-send-email-clabbe.montjoie@gmail.com>
 <20161010123151.GI3462@lukather>
 <20161010145021.00586f772e3398833217796a@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0554972073721425790=="
Cc: mark.rutland@arm.com, andrew@lunn.ch, f.fainelli@gmail.com,
 devicetree@vger.kernel.org, netdev@vger.kernel.org, linux@armlinux.org.uk,
 linux-kernel@vger.kernel.org, wens@csie.org, robh+dt@kernel.org,
 Corentin Labbe <clabbe.montjoie@gmail.com>, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Jean-Francois Moine <moinejf@free.fr>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20161010145021.00586f772e3398833217796a@free.fr>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--===============0554972073721425790==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HjGz34yYE1BNnn/x"
Content-Disposition: inline


--HjGz34yYE1BNnn/x
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 10, 2016 at 02:50:21PM +0200, Jean-Francois Moine wrote:
> On Mon, 10 Oct 2016 14:31:51 +0200
> Maxime Ripard <maxime.ripard@free-electrons.com> wrote:
>=20
> > Hi,
> >=20
> > On Fri, Oct 07, 2016 at 10:25:51AM +0200, Corentin Labbe wrote:
> > > This patch add the dt node for the syscon register present on the
> > > Allwinner H3.
> > >=20
> > > Only two register are present in this syscon and the only one useful =
is
> > > the one dedicated to EMAC clock.
> > >=20
> > > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> > > ---
> > >  arch/arm/boot/dts/sun8i-h3.dtsi | 5 +++++
> > >  1 file changed, 5 insertions(+)
> > >=20
> > > diff --git a/arch/arm/boot/dts/sun8i-h3.dtsi b/arch/arm/boot/dts/sun8=
i-h3.dtsi
> > > index 8a95e36..1101d2f 100644
> > > --- a/arch/arm/boot/dts/sun8i-h3.dtsi
> > > +++ b/arch/arm/boot/dts/sun8i-h3.dtsi
> > > @@ -140,6 +140,11 @@
> > >  		#size-cells =3D <1>;
> > >  		ranges;
> > > =20
> > > +		syscon: syscon@01c00000 {
> > > +			compatible =3D "syscon";
> >=20
> > It would be great to have a more specific compatible here in addition
> > to the syscon, like "allwinner,sun8i-h3-system-controller".
>=20
> The System Control area is just like the PRCM area: it would be simpler
> to define the specific registers in the associated drivers.

Until you actually have to share those registers between different
devices, and then you're just screwed.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--HjGz34yYE1BNnn/x
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX/LNXAAoJEBx+YmzsjxAgBFIQAIQImmQm2o+Nd8KucZ2JccEs
lEdcGOjSex7qY+kS//VCZ3fbnnCUjw1UwoDTL/stm0VmW2NFWkO4qPj+DaRLek4D
Xh/gCM8tIft04xFIJ3YKia9rpaKbvZVM4K8elHsp4q/cuwHHsbLHYz1OsVPX7jlH
uJ5ZYASQChT8MNA95PJBn2uUoX7KNsUCoGGhJ1fyUUfkG869+//I+bYVS+r2Vf1J
ASbQYVkADN/nAaywJwVnJookVhOSk/JMTnTSdGCtrOEivJ0XSqksKOBt2eXvB6UI
BRHzcnkwUJ6j4xYbAAtTlp8cZL9TcEB+8H19wIPX85hz/NUtSaBPBwENtEUY2TBY
ZZQDA1npub/gllKE+vefcA5GC9jUu/nGg6oXEOp0xfQd+zkf/yAaTmE7DXtCazPJ
w4MjLtolgN/Io3IIpqV9CLAiLJ5e74S3qEHmm6X0OgMXyGB1XEi+Xo1S83R28n+H
yIC/nLrZs8ovZwxF2RYeP6jo2XXCAzdtAi8R3ezEXq36M57rWX8azxgDc+FXGwrP
J4/7mRspqCNIHJ2WbwOn9bQA7/FcPJQOZmc2ZstoNsv+3SuJYkCq3QQs+cny77FO
OGXMQ/4682wafakPINotRSTeZc+Z73GPSiqhmmXmpXut8JFdUzXosyXQOqjlxCXx
vGZ6GBcwTsdPGwFiZBuY
=X3Vn
-----END PGP SIGNATURE-----

--HjGz34yYE1BNnn/x--


--===============0554972073721425790==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============0554972073721425790==--
