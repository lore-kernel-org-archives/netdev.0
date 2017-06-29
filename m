From: icenowy-h8G6r0blFSE@public.gmane.org
Subject: Re: Re: [PATCH 1/6] net: stmmac: support future
 possible different internal phy mode
Date: Fri, 30 Jun 2017 00:46:30 +0800
Message-ID: <9f1992d1cab37e5f309c6260985ce32a@aosc.io>
References: <20170627092806.28181-1-clabbe.montjoie@gmail.com>
 <20170629.122349.2265868886957558079.davem@davemloft.net>
Reply-To: icenowy-h8G6r0blFSE@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
 linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
 peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org, andre.przywara-5wv7dgnIgG8@public.gmane.org,
 devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-sunxi+bncBDS6XAN6ZADRB2652TFAKGQE264TGXQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170629.122349.2265868886957558079.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

=E5=9C=A8 2017-06-30 00:23=EF=BC=8CDavid Miller =E5=86=99=E9=81=93=EF=BC=9A
> From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Tue, 27 Jun 2017 11:28:01 +0200
>=20
>> The current way to find if the phy is internal is to compare DT=20
>> phy-mode
>> and emac_variant/internal_phy.
>> But it will negate a possible future SoC where an external PHY use the
>> same phy mode than the internal one.
>>=20
>> By using phy-mode =3D "internal" we permit to have an external PHY with
>> the same mode than the internal one.
>>=20
>> Reported-by: Andr=C3=A9 Przywara <andre.przywara-5wv7dgnIgG8@public.gmane.org>
>> Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>=20
> Series applied.

I think there's still some problems around for this patchset...
The definition of "internal" is internal *proprietary* PHY, but the
internal PHY of Allwinner SoCs seem to be MII...

See [1].

[1]=20
http://lists.infradead.org/pipermail/linux-arm-kernel/2017-June/516159.html

>=20
> Please provide a proper "[PATCH 0/n] " header posting next time.

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
