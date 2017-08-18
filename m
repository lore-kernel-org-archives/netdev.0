From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v2 0/6] net: stmmac: Detect PHY location with
 phy-is-integrated
Date: Fri, 18 Aug 2017 11:24:27 +0200
Message-ID: <20170818092427.GA7425@Red>
References: <20170817075149.16178-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: robh+dt@kernel.org, mark.rutland@arm.com, linux@armlinux.org.uk,
        maxime.ripard@free-electrons.com, wens@csie.org,
        peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170817075149.16178-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 17, 2017 at 09:51:43AM +0200, Corentin Labbe wrote:
> Hello
> 
> The current way to find if the phy is internal is to compare DT phy-mode
> and emac_variant/internal_phy.
> But it will negate a possible future SoC where an external PHY use the
> same phy mode than the integrated one.
> 
> This patchs series adds a new way to find if the PHY is integrated, via
> the phy-is-integrated DT property.
> 
> Since it exists both integrated and external ethernet-phy@1, they are merged in
> the final DTB and so share all properties.
> For avoiding this, the phy-is-integrated is added only to board DT.
> 
> The first five patchs should go via the sunxi tree.
> the last one should go via the net tree.
> Note that this serie will need backporting the patch
> "Documentation: net: phy: Add phy-is-integrated binding" which is in net-next
> 
> Thanks
> Regards
> 
> Changes since v1:
> - Dropped phy-is-integrated documentation patch since another same patch was already merged
> - Moved phy-is-integrated from SoC dtsi to final board DT.
> 
> Corentin Labbe (6):
>   ARM: sun8i: orangepipc: Set phy-is-integrated to the internal phy node
>   ARM: sun8i: beelink-x2: Set phy-is-integrated to the internal phy node
>   ARM: sun8i: nanopi-neo: Set phy-is-integrated to the internal phy node
>   ARM: sun8i: orangepi-2: Set phy-is-integrated to the internal phy node
>   ARM: sun8i: orangepi-one: Set phy-is-integrated to the internal phy
>     node
>   net: stmmac: dwmac-sun8i: choose internal PHY via phy-is-integrated
> 
>  arch/arm/boot/dts/sun8i-h3-beelink-x2.dts         |  4 ++++
>  arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts         |  4 ++++
>  arch/arm/boot/dts/sun8i-h3-orangepi-2.dts         |  4 ++++
>  arch/arm/boot/dts/sun8i-h3-orangepi-one.dts       |  4 ++++
>  arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts        |  4 ++++
>  drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c | 16 ++++++++--------
>  6 files changed, 28 insertions(+), 8 deletions(-)
> 
> -- 
> 2.13.0
> 

Hello

Self NACK, the comment from Rob on previous series is pertinent.
I will send a v3 which use a mdio-mux for solving all problems.

Regards
