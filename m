From: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
Subject: Re: Re: [PATCH 04/21] ARM: sun8i: dt: Add DT bindings
 documentation for Allwinner dwmac-sun8i
Date: Sat, 18 Feb 2017 06:39:26 +0800
Message-ID: <20170218013936.dTFqwiSq@smtp2h.mail.yandex.net>
Reply-To: icenowy-ymACFijhrKM@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: alexandre.torgue-qxv4g6HH51o@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 mark.rutland-5wv7dgnIgG8@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
 Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBCZLPFN5Q4OBBNHXTXCQKGQEMMD4T6I-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org


2017=E5=B9=B42=E6=9C=8817=E6=97=A5 04:58=E4=BA=8E Florian Fainelli <f.faine=
lli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=E5=86=99=E9=81=93=EF=BC=9A
>
> On 02/16/2017 04:48 AM, Corentin Labbe wrote:=20
> > This patch adds documentation for Device-Tree bindings for the=20
> > Allwinner dwmac-sun8i driver.=20
> >=20
> > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=20
> > ---=20
> >=C2=A0 .../devicetree/bindings/net/dwmac-sun8i.txt=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 | 86 ++++++++++++++++++++++=20
> >=C2=A0 1 file changed, 86 insertions(+)=20
> >=C2=A0 create mode 100644 Documentation/devicetree/bindings/net/dwmac-su=
n8i.txt=20
> >=20
> > diff --git a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt b/Do=
cumentation/devicetree/bindings/net/dwmac-sun8i.txt=20
> > new file mode 100644=20
> > index 0000000..ac806c6=20
> > --- /dev/null=20
> > +++ b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt=20
> > @@ -0,0 +1,86 @@=20
> > +* Allwinner sun8i GMAC ethernet controller=20
> > +=20
> > +This device is a platform glue layer for stmmac.=20
> > +Please see stmmac.txt for the other unchanged properties.=20
> > +=20
> > +Required properties:=20
> > +- compatible: should be one of the following string:=20
> > + "allwinner,sun8i-a83t-emac"=20
> > + "allwinner,sun8i-h3-emac"=20
> > + "allwinner,sun50i-a64-emac"=20
> > +- reg: address and length of the register for the device.=20
> > +- interrupts: interrupt for the device=20
> > +- interrupt-names: should be "macirq"=20
> > +- clocks: A phandle to the reference clock for this device=20
> > +- clock-names: should be "stmmaceth"=20
> > +- resets: A phandle to the reset control for this device=20
> > +- reset-names: should be "stmmaceth"=20
> > +- phy-mode: See ethernet.txt=20
> > +- phy-handle: See ethernet.txt=20
> > +- #address-cells: shall be 1=20
> > +- #size-cells: shall be 0=20
> > +- syscon: A phandle to the syscon of the SoC with one of the following=
=20
> > + compatible string:=20
> > +=C2=A0 - allwinner,sun8i-h3-system-controller=20
> > +=C2=A0 - allwinner,sun8i-a64-system-controller=20
> > +=C2=A0 - allwinner,sun8i-a83t-system-controller=20
> > +=20
> > +Optional properties:=20
> > +- allwinner,tx-delay: TX clock delay chain value. Range value is 0-0x0=
7. Default is 0)=20
> > +- allwinner,rx-delay: RX clock delay chain value. Range value is 0-0x1=
F. Default is 0)=20
>
> Delays should be specified in nanosecond units, and should not be a=20
> value that maps directly to a HW register value, you need to convert the=
=20
> property value into the appropriate register value.=20
>
> > +Both delay properties does not have units, there are arbitrary value.=
=20
> > +The TX/RX clock delay chain settings are board specific and could be f=
ound=20
> > +in vendor FEX files.=20
> > +=20
> > +Optional properties for "allwinner,sun8i-h3-emac":=20
> > +- allwinner,leds-active-low: EPHY LEDs are active low=20
>
> Are you sure this is appropriate at the MAC node level and this is not=20
> something that follows the PHY instead?=20

I think it's in fact for the internal MII PHY.

Allwinner H3/H5/V3s features a internal PHY in the SoC (V3s even lacks an e=
xternal MII interface), which is also handled in this driver.

>
> > +=20
> > +Required child node of emac:=20
> > +- mdio bus node: should be named mdio=20
> > +=20
> > +Required properties of the mdio node:=20
> > +- #address-cells: shall be 1=20
> > +- #size-cells: shall be 0=20
> > +=20
> > +The device node referenced by "phy" or "phy-handle" should be a child =
node=20
> > +of the mdio node. See phy.txt for the generic PHY bindings.=20
> > +=20
> > +Required properties of the phy node with "allwinner,sun8i-h3-emac":=20
> > +- clocks: an extra phandle to the reference clock for the EPHY=20
>
> s/an extra/a phandle/=20
>
> > +- resets: an extra phandle to the reset control for the EPHY=20
> > +=20
> > +Required properties for the system controller:=20
> > +- reg: address and length of the register for the device.=20
> > +- compatible: should be "syscon" and one of the following string:=20
> > + "allwinner,sun8i-h3-system-controller"=20
> > + "allwinner,sun8i-a64-system-controller"=20
> > + "allwinner,sun8i-a83t-system-controller"=20
> > +=20
> > +Example:=20
> > +=20
> > +emac: ethernet@1c0b000 {=20
> > + compatible =3D "allwinner,sun8i-h3-emac";=20
> > + syscon =3D <&syscon>;=20
> > + reg =3D <0x01c0b000 0x104>;=20
> > + interrupts =3D <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;=20
> > + interrupt-names =3D "macirq";=20
> > + resets =3D <&ccu RST_BUS_EMAC>;=20
> > + reset-names =3D "stmmaceth";=20
> > + clocks =3D <&ccu CLK_BUS_EMAC>;=20
> > + clock-names =3D "stmmaceth";=20
> > + #address-cells =3D <1>;=20
> > + #size-cells =3D <0>;=20
> > +=20
> > + phy =3D <&int_mii_phy>;=20
> > + phy-mode =3D "mii";=20
> > + allwinner,leds-active-low;=20
> > + mdio: mdio {=20
> > + #address-cells =3D <1>;=20
> > + #size-cells =3D <0>;=20
> > + int_mii_phy: ethernet-phy@1 {=20
> > + reg =3D <1>;=20
> > + clocks =3D <&ccu CLK_BUS_EPHY>;=20
> > + resets =3D <&ccu RST_BUS_EPHY>;=20
> > + };=20
> > + };=20
> > +};=20
> >=20
>
>
> --=20
> Florian=20
>
> --=20
> You received this message because you are subscribed to the Google Groups=
 "linux-sunxi" group.=20
> To unsubscribe from this group and stop receiving emails from it, send an=
 email to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org=20
> For more options, visit https://groups.google.com/d/optout.=20

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
