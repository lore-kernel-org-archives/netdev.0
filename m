From: Mahesh Nanavalla <mahesh.nanavalla-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/5] net-next: ethernet: add sun8i-emac driver
Date: Fri, 12 May 2017 06:09:17 -0700 (PDT)
Message-ID: <593bffd3-a04a-421b-86d4-ed3035c79445@googlegroups.com>
References: <1464947790-22991-1-git-send-email-clabbe.montjoie@gmail.com>
Reply-To: mahesh.nanavalla-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_6076_339322027.1494594557960"
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Return-path: <linux-sunxi+bncBDQ4N35GZUMBBTPT23EAKGQERLXI4QY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <1464947790-22991-1-git-send-email-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

------=_Part_6076_339322027.1494594557960
Content-Type: multipart/alternative;
	boundary="----=_Part_6077_1112402886.1494594557960"

------=_Part_6077_1112402886.1494594557960
Content-Type: text/plain; charset="UTF-8"

Hi All,

I am new to Ethernet Driver.

I am working on NanoPI Neo Based on SUN8i-H3 SOC ...

can any body helpout to up the Ethernet on The NanoPi Neo.



On Friday, June 3, 2016 at 3:27:19 PM UTC+5:30, clabbe.montjoie wrote:
>
> Hello 
>
> This patch series add the driver for sun8i-emac which handle the Ethernet 
> MAC 
> present on Allwinner H3/A83T/A64 SoCs. 
>
> It supports 10/100/1000 Mbit/s speed with half/full duplex. 
> It can use an internal PHY (MII 10/100) or an external PHY 
> via RGMII/RMII. 
>
> This patch series enable the driver only for the H3 SoC since A83T and A64 
> doesn't have the necessary clocks present in mainline. 
>
> This patch series enable the driver only for the OrangePiPC board since 
> other 
> board with H3 use external PHY which need optional regulators that will be 
> supported later. 
>
> The driver have been tested on the following boards: 
> - H3 Orange PI PC, Orange PI Plus, BananaPI-M2+ 
> - A64 Pine64 
> - A83T BananaPI-M3 
>
> I would like to thanks Chen-Yu Tsai for his help on developing this 
> driver. 
>
> Regards 
>
> LABBE Corentin (5): 
>   ethernet: add sun8i-emac driver 
>   MAINTAINERS: Add myself as maintainers of sun8i-emac 
>   ARM: sun8i: dt: Add DT bindings documentation for Allwinner sun8i-emac 
>   ARM: dts: sun8i-h3: add sun8i-emac ethernet driver 
>   ARM: dts: sun8i: Enable sun8i-emac on the Orange PI PC 
>
>  .../bindings/net/allwinner,sun8i-emac.txt          |   64 + 
>  MAINTAINERS                                        |    6 + 
>  arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts         |   11 + 
>  arch/arm/boot/dts/sun8i-h3.dtsi                    |   14 + 
>  drivers/net/ethernet/allwinner/Kconfig             |   13 + 
>  drivers/net/ethernet/allwinner/Makefile            |    1 + 
>  drivers/net/ethernet/allwinner/sun8i-emac.c        | 1943 
> ++++++++++++++++++++ 
>  7 files changed, 2052 insertions(+) 
>  create mode 100644 
> Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt 
>  create mode 100644 drivers/net/ethernet/allwinner/sun8i-emac.c 
>
> -- 
> 2.7.3 
>
>

-- 
You received this message because you are subscribed to the Google Groups "linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.

------=_Part_6077_1112402886.1494594557960
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi All,<div><br></div><div>I am new to Ethernet Driver.</d=
iv><div><br></div><div>I am working on NanoPI Neo Based on SUN8i-H3 SOC ...=
</div><div><br></div><div>can any body helpout to up the Ethernet on The Na=
noPi Neo.</div><div><br></div><div><br><br>On Friday, June 3, 2016 at 3:27:=
19 PM UTC+5:30, clabbe.montjoie wrote:<blockquote class=3D"gmail_quote" sty=
le=3D"margin: 0;margin-left: 0.8ex;border-left: 1px #ccc solid;padding-left=
: 1ex;">Hello
<br>
<br>This patch series add the driver for sun8i-emac which handle the Ethern=
et MAC
<br>present on Allwinner H3/A83T/A64 SoCs.
<br>
<br>It supports 10/100/1000 Mbit/s speed with half/full duplex.
<br>It can use an internal PHY (MII 10/100) or an external PHY
<br>via RGMII/RMII.
<br>
<br>This patch series enable the driver only for the H3 SoC since A83T and =
A64
<br>doesn&#39;t have the necessary clocks present in mainline.
<br>
<br>This patch series enable the driver only for the OrangePiPC board since=
 other
<br>board with H3 use external PHY which need optional regulators that will=
 be
<br>supported later.
<br>
<br>The driver have been tested on the following boards:
<br>- H3 Orange PI PC, Orange PI Plus, BananaPI-M2+
<br>- A64 Pine64
<br>- A83T BananaPI-M3
<br>
<br>I would like to thanks Chen-Yu Tsai for his help on developing this dri=
ver.
<br>
<br>Regards
<br>
<br>LABBE Corentin (5):
<br>=C2=A0 ethernet: add sun8i-emac driver
<br>=C2=A0 MAINTAINERS: Add myself as maintainers of sun8i-emac
<br>=C2=A0 ARM: sun8i: dt: Add DT bindings documentation for Allwinner sun8=
i-emac
<br>=C2=A0 ARM: dts: sun8i-h3: add sun8i-emac ethernet driver
<br>=C2=A0 ARM: dts: sun8i: Enable sun8i-emac on the Orange PI PC
<br>
<br>=C2=A0.../bindings/net/allwinner,<wbr>sun8i-emac.txt =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0| =C2=A0 64 +
<br>=C2=A0MAINTAINERS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0| =C2=A0 =C2=A06 +
<br>=C2=A0arch/arm/boot/dts/sun8i-h3-<wbr>orangepi-pc.dts =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 | =C2=A0 11 +
<br>=C2=A0arch/arm/boot/dts/sun8i-h3.<wbr>dtsi =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 14 +
<br>=C2=A0drivers/net/ethernet/<wbr>allwinner/Kconfig =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 | =C2=A0 13 +
<br>=C2=A0drivers/net/ethernet/<wbr>allwinner/Makefile =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01 +
<br>=C2=A0drivers/net/ethernet/<wbr>allwinner/sun8i-emac.c =C2=A0 =C2=A0 =
=C2=A0 =C2=A0| 1943 ++++++++++++++++++++
<br>=C2=A07 files changed, 2052 insertions(+)
<br>=C2=A0create mode 100644 Documentation/devicetree/<wbr>bindings/net/all=
winner,sun8i-<wbr>emac.txt
<br>=C2=A0create mode 100644 drivers/net/ethernet/<wbr>allwinner/sun8i-emac=
.c
<br>
<br>--=20
<br>2.7.3
<br>
<br></blockquote></div></div>

<p></p>

-- <br />
You received this message because you are subscribed to the Google Groups &=
quot;linux-sunxi&quot; group.<br />
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to <a href=3D"mailto:linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org">linux-s=
unxi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org</a>.<br />
For more options, visit <a href=3D"https://groups.google.com/d/optout">http=
s://groups.google.com/d/optout</a>.<br />

------=_Part_6077_1112402886.1494594557960--

------=_Part_6076_339322027.1494594557960--
