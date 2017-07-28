From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: [PATCH 0/3] net-next: stmmac: support future
 possible different internal phy mode
Date: Fri, 28 Jul 2017 17:53:40 +0800
Message-ID: <CAGb2v66=h_5df=B0Us-kvvFg9r_qSUroDzn-xvQLSpD1d8DhBQ@mail.gmail.com>
References: <20170728092818.23419-1-clabbe.montjoie@gmail.com>
Reply-To: wens-jdAy2FN1RRM@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>, Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
	Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBPET5TFQKGQETAAF2VI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170728092818.23419-1-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 5:28 PM, Corentin Labbe
<clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Hello
>
> The current way to find if the phy is internal is to compare DT phy-mode
> and emac_variant/internal_phy.
> But it will negate a possible future SoC where an external PHY use the
> same phy mode than the internal one.
>
> This patchs series adds a new way to find if the PHY is internal, via its
> compatible.

You've already joined in on the discussion for the patch "net: stmmac:
dwmac-rk: Add internal phy support". It is pretty much the same issue.
Please wait for it to come to a proper conclusion. At least then we can
agree on something so different platforms with the same problem don't
have diverging solutions.

ChenYu

>
> Corentin Labbe (3):
>   dt-bindings: net: add compatible for internal sun8i-h3/sun8i-v3s PHYs
>   ARM: sunxi: h3/h5: Add sun8i-h3-ephy compatible
>   net-next: stmmac: dwmac-sun8i: choose internal PHY via compatible
>
>  Documentation/devicetree/bindings/net/dwmac-sun8i.txt |  4 ++--
>  arch/arm/boot/dts/sunxi-h3-h5.dtsi                    |  3 ++-
>  drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c     | 16 ++++++++++------
>  3 files changed, 14 insertions(+), 9 deletions(-)
>
> --
> 2.13.0
>
