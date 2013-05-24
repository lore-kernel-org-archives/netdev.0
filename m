From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCHv3 5/6] ARM: cubieboard: Enable ethernet (EMAC) support in
 dts
Date: Fri, 24 May 2013 22:15:39 +0200
Message-ID: <20130524201539.GB17847@lukather>
References: <1369387394-9453-1-git-send-email-maxime.ripard@free-electrons.com>
 <1369387394-9453-6-git-send-email-maxime.ripard@free-electrons.com>
 <519F62B3.8090302@elopez.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Roese <sr@denx.de>,
	Florian Fainelli <florian@openwrt.org>,
	kevin@allwinnertech.com, sunny@allwinnertech.com,
	shuge@allwinnertech.com
To: Emilio =?iso-8859-1?Q?L=F3pez?= <emilio@elopez.com.ar>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <519F62B3.8090302@elopez.com.ar>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Emilio,

On Fri, May 24, 2013 at 09:53:07AM -0300, Emilio L=F3pez wrote:
> Hi,
>=20
> El 24/05/13 06:23, Maxime Ripard escribi=F3:
> > From: Stefan Roese <sr@denx.de>
> >=20
> > Signed-off-by: Stefan Roese <sr@denx.de>
> > ---
> >  arch/arm/boot/dts/sun4i-a10-cubieboard.dts | 15 +++++++++++++++
> >  1 file changed, 15 insertions(+)
> >=20
> > diff --git a/arch/arm/boot/dts/sun4i-a10-cubieboard.dts b/arch/arm/=
boot/dts/sun4i-a10-cubieboard.dts
> > index b70fe0d..32d9b18 100644
> > --- a/arch/arm/boot/dts/sun4i-a10-cubieboard.dts
> > +++ b/arch/arm/boot/dts/sun4i-a10-cubieboard.dts
> > @@ -27,6 +27,21 @@
> >  	};
> > =20
> >  	soc@01c20000 {
> > +		emac: ethernet@01c0b000 {
> > +			pinctrl-names =3D "default";
> > +			pinctrl-0 =3D <&emac_pins_a>;
> > +			phy =3D <&phy0>;
> > +			status =3D "okay";
> > +		};
> > +
> > +		mdio@01c0b080 {
> > +			status =3D "okay";
> > +
> > +			phy0: ethernet-phy@0 {
> > +				reg =3D <0>;
> > +			};
>=20
> During my testing I found out that I needed to use 1 as reg for the
> driver to work. You can find a fixup patch enclosed that changes this=
;
> it's possible that some extra changes may also be needed (s/phy0/phy1=
/
> on the node?)

Merged, thanks for noticing!

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
