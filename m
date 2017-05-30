From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] ARM: dts: imx6ul-14x14-evk: Add ksz8081 phy
 properties
Date: Tue, 30 May 2017 11:10:19 -0700
Message-ID: <46bde649-c9ce-5a87-d4c4-1c1ebc5a8923@gmail.com>
References: <cover.1496164448.git.leonard.crestez@nxp.com>
 <d31aab90fbdecaf4c5f240becb2d0b0efb23f5c3.1496164448.git.leonard.crestez@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Johan Hovold <johan@kernel.org>,
        Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Philipp Zabel <p.zabel@pengutronix.de>,
        Fabio Estevam <fabio.estevam@nxp.com>, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Leonard Crestez <leonard.crestez@nxp.com>,
        Shawn Guo <shawnguo@kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        Andy Duan <fugang.duan@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d31aab90fbdecaf4c5f240becb2d0b0efb23f5c3.1496164448.git.leonard.crestez@nxp.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/30/2017 10:34 AM, Leonard Crestez wrote:
> Right now mach-imx6ul registers a fixup for the ksz8081 phy. The same
> register values can be set through the micrel phy driver by using dts
> properties.
> 
> This seems preferable and allows cleanly fixing suspend/resume.
> 
> Signed-off-by: Leonard Crestez <leonard.crestez@nxp.com>

Should you have a Fixes: tag for that? Sounds like something you'd want
to backport to stable trees as well, no?

> ---
>  arch/arm/boot/dts/imx6ul-14x14-evk.dts | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/arch/arm/boot/dts/imx6ul-14x14-evk.dts b/arch/arm/boot/dts/imx6ul-14x14-evk.dts
> index f18e1f1..d2be8aa 100644
> --- a/arch/arm/boot/dts/imx6ul-14x14-evk.dts
> +++ b/arch/arm/boot/dts/imx6ul-14x14-evk.dts
> @@ -120,10 +120,16 @@
>  
>  		ethphy0: ethernet-phy@2 {
>  			reg = <2>;
> +			micrel,led-mode = <1>;
> +			clocks = <&clks IMX6UL_CLK_ENET_REF>;
> +			clock-names = "rmii-ref";
>  		};
>  
>  		ethphy1: ethernet-phy@1 {
>  			reg = <1>;
> +			micrel,led-mode = <1>;
> +			clocks = <&clks IMX6UL_CLK_ENET2_REF>;
> +			clock-names = "rmii-ref";
>  		};
>  	};
>  };
> 


-- 
Florian
