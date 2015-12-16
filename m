From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3] net/macb: add support for resetting PHY using GPIO
Date: Wed, 16 Dec 2015 20:04:31 +0100
Message-ID: <20151216190431.GB28759@localhost.localdomain>
References: <1450290690-32369-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Russell King <linux@arm.linux.org.uk>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1450290690-32369-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 16, 2015 at 07:31:30PM +0100, Gregory CLEMENT wrote:
> +Optional properties for PHY child node:
> +- reset-gpios : Should specify the gpio for phy reset

reset-gpios plural or reset-gpio singular?

> +
>  Examples:
>  
>  	macb0: ethernet@fffc4000 {
> @@ -29,4 +32,8 @@ Examples:
>  		local-mac-address = [3a 0e 03 04 05 06];
>  		clock-names = "pclk", "hclk", "tx_clk";
>  		clocks = <&clkc 30>, <&clkc 30>, <&clkc 13>;
> +		ethernet-phy@1 {
> +			reg = <0x1>;
> +			reset-gpios = <&pioE 6 1>;

Did you mean "gpioE" ?

Thanks,
Richard
