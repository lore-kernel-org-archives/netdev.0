From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v7 10/10] of: mdio: Prevent of_mdiobus_register from
 scanning mdio-mux nodes
Date: Tue, 24 Oct 2017 13:46:54 -0500
Message-ID: <20171024184654.ggfrsrjd3nobku5n@rob-hp-laptop>
References: <20171018114458.17891-1-clabbe.montjoie@gmail.com>
 <20171018114458.17891-11-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mark.rutland@arm.com, maxime.ripard@free-electrons.com,
        wens@csie.org, linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com,
        frowand.list@gmail.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, linux-sunxi@googlegroups.com
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171018114458.17891-11-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 18, 2017 at 01:44:58PM +0200, Corentin Labbe wrote:
> Each child node of an MDIO node is scanned as a PHY when calling
> of_mdiobus_register() givint the following result:
> [   18.175379] mdio_bus stmmac-0: /soc/ethernet@1c30000/mdio/mdio-mux has invalid PHY address
> [   18.175408] mdio_bus stmmac-0: scan phy mdio-mux at address 0
> [   18.175450] mdio_bus stmmac-0: scan phy mdio-mux at address 1
> [...]
> [   18.176420] mdio_bus stmmac-0: scan phy mdio-mux at address 30
> [   18.176452] mdio_bus stmmac-0: scan phy mdio-mux at address 31
> 
> Since mdio-mux nodes are not PHY, this patch a way to to not scan
> them.

This can be dropped now, right?
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  drivers/of/of_mdio.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
