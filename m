From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: [PATCH 0/4] net: stmmac: revert the EMAC bindings
Date: Sun, 27 Aug 2017 20:42:08 +0800
Message-ID: <CAGb2v651W0MccX6hTqKKpbpJBD4YVyZjGUET-HZuFhG_mqFRmg@mail.gmail.com>
References: <20170825191217.10278-1-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: arm-soc <arm@kernel.org>, David Miller <davem@davemloft.net>,
        Chen-Yu Tsai <wens@csie.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        LABBE Corentin <clabbe.montjoie@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825191217.10278-1-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 26, 2017 at 3:12 AM, Maxime Ripard
<maxime.ripard@free-electrons.com> wrote:
> Hi,
>
> The bindings of the stmmac glue for the new Allwinner EMAC controller
> are still controversial and being discussed, even though they've been
> merged in 4.13.
>
> In order not to introduce any binding we do not really want to commit
> to in a stable release, especially since that would mean we would have
> to support both the right and old bindings, let's revert them.
>
> We will reintroduce them in due time, once the discussion has settled
> down.
>
> The first three patches should go through the arm-soc tree, the last
> one through the net tree. All of them must be treated as fixes.
>
> Thanks!
> Maxime
>
> Maxime Ripard (4):
>   dt-bindings: net: Revert sun8i dwmac binding
>   arm64: dts: allwinner: Revert EMAC changes
>   arm: dts: sunxi: Revert EMAC changes
>   net: stmmac: sun8i: Remove the compatibles
>
>  .../devicetree/bindings/net/dwmac-sun8i.txt        | 84 ----------------------
>  arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts  |  9 ---
>  arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts    | 19 -----
>  arch/arm/boot/dts/sun8i-h3-beelink-x2.dts          |  8 ---

I think this particular change is in -next, not v4.13-rc.

Otherwise, whole series is

Acked-by: Chen-Yu Tsai <wens@csie.org>

>  arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts          |  7 --
>  arch/arm/boot/dts/sun8i-h3-orangepi-2.dts          |  8 ---
>  arch/arm/boot/dts/sun8i-h3-orangepi-one.dts        |  8 ---
>  arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts    |  5 --
>  arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts         |  8 ---
>  arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts       | 22 ------
>  arch/arm/boot/dts/sun8i-h3-orangepi-plus2e.dts     | 16 -----
>  arch/arm/boot/dts/sunxi-h3-h5.dtsi                 | 26 -------
>  .../boot/dts/allwinner/sun50i-a64-bananapi-m64.dts | 17 -----
>  .../boot/dts/allwinner/sun50i-a64-pine64-plus.dts  | 15 ----
>  .../arm64/boot/dts/allwinner/sun50i-a64-pine64.dts | 18 -----
>  .../dts/allwinner/sun50i-a64-sopine-baseboard.dts  | 17 -----
>  arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi      | 20 ------
>  .../boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts   | 17 -----
>  .../boot/dts/allwinner/sun50i-h5-orangepi-pc2.dts  | 17 -----
>  .../dts/allwinner/sun50i-h5-orangepi-prime.dts     | 17 -----
>  drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c  |  8 ---
>  21 files changed, 366 deletions(-)
>  delete mode 100644 Documentation/devicetree/bindings/net/dwmac-sun8i.txt
>
> --
> 2.13.5
>
