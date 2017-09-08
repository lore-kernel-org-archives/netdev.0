From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] dt-bindings: net: add DT bindings for
 Socionext UniPhier AVE
Date: Fri, 8 Sep 2017 16:03:22 +0200
Message-ID: <20170908140322.GD25219@lunn.ch>
References: <1504875731-3680-1-git-send-email-hayashi.kunihiko@socionext.com>
 <1504875731-3680-2-git-send-email-hayashi.kunihiko@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Masami Hiramatsu <masami.hiramatsu@linaro.org>,
        Jassi Brar <jaswinder.singh@linaro.org>
To: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1504875731-3680-2-git-send-email-hayashi.kunihiko@socionext.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +	eth: ethernet@65000000 {
> +		compatible = "socionext,uniphier-ave4";
> +		reg = <0x65000000 0x8500>;
> +		interrupts = <0 66 4>;
> +		pinctrl-names = "default";
> +		pinctrl-0 = <&pinctrl_ether_rgmii>;
> +		phy-mode = "rgmii";
> +		socionext,desc-bits = <64>;
> +		local-mac-address = [00 00 00 00 00 00];
> +
> +		#address-cells = <1>;
> +		#size-cells = <0>;

> +		ethphy: ethphy@1 {
> +			reg = <1>;
> +		};


So you normally have an mdio node, and the phy as a children of that
node.

       mdio {
                ethphy: ethernet-phy@6 {
                        reg = <6>;
                };
        };

	Andrew
