From: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
Subject: Re: Re: [PATCH 20/21] ARM: sunxi: Enable dwmac-sun8i
 driver on sunxi_defconfig
Date: Sat, 18 Feb 2017 06:34:53 +0800
Message-ID: <20170218013506.YwCWCcZO@smtp2o.mail.yandex.net>
Reply-To: icenowy-ymACFijhrKM@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: alexandre.torgue-qxv4g6HH51o@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org, Maxime Ripard
 <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
 devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBCZLPFN5Q4OBBJHVTXCQKGQENQ7BK3I-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org


2017=E5=B9=B42=E6=9C=8817=E6=97=A5 16:55=E4=BA=8E Corentin Labbe <clabbe.mo=
ntjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=E5=86=99=E9=81=93=EF=BC=9A
>
> On Thu, Feb 16, 2017 at 08:08:27PM +0100, Maxime Ripard wrote:=20
> > Hi,=20
> >=20
> > On Thu, Feb 16, 2017 at 01:48:58PM +0100, Corentin Labbe wrote:=20
> > > From: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=20
> > >=20
> > > Enable the dwmac-sun8i driver in the sunxi default configuration=20
> > >=20
> > > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=20
> > > ---=20
> > >=C2=A0 arch/arm/configs/sunxi_defconfig | 1 +=20
> > >=C2=A0 1 file changed, 1 insertion(+)=20
> > >=20
> > > diff --git a/arch/arm/configs/sunxi_defconfig b/arch/arm/configs/sunx=
i_defconfig=20
> > > index da92c25..33bde86 100644=20
> > > --- a/arch/arm/configs/sunxi_defconfig=20
> > > +++ b/arch/arm/configs/sunxi_defconfig=20
> > > @@ -40,6 +40,7 @@ CONFIG_ATA=3Dy=20
> > >=C2=A0 CONFIG_AHCI_SUNXI=3Dy=20
> > >=C2=A0 CONFIG_NETDEVICES=3Dy=20
> > >=C2=A0 CONFIG_SUN4I_EMAC=3Dy=20
> > > +CONFIG_DWMAC_SUN8I=3Dm=20
> >=20
> > I think I'd prefer to have it compiled statically, just like the other=
=20
> > net drivers, and drivers in general.=20
> >=20
> > Thanks!=20
> > Maxime=20
> >=20
>
> In previous sun8i-emac, someone request that CONFIG must be set as module=
 because kernel went too big.=20
> But I do not care to set it statically.=20

This is sunxi_defconfig, not multi_v7_config.

I remember the complain is for multi_v7_config.

For multi_v7_config it's proper to make it =3Dm.

>
> Regards=20
> Corentin Labbe=20
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
