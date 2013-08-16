From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5 1/2] ARM: davinci: da850: add DT node for ethernet
Date: Fri, 16 Aug 2013 22:46:15 +0400
Message-ID: <520E7377.1080808@cogentembedded.com>
References: <1376662262-21795-1-git-send-email-prabhakar.csengg@gmail.com> <1376662262-21795-2-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sekhar Nori <nsekhar@ti.com>,
	DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	LKML <linux-kernel@vger.kernel.org>,
	linux-arm-kernel@lists.infradead.org
To: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376662262-21795-2-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 08/16/2013 06:11 PM, Lad, Prabhakar wrote:

> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

> Add ethernet device tree node information and pinmux for mii to da850 by
> providing interrupt details and local mac address.

> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
> ---
>   arch/arm/boot/dts/da850-evm.dts |    5 +++++
>   arch/arm/boot/dts/da850.dtsi    |   30 ++++++++++++++++++++++++++++++
>   2 files changed, 35 insertions(+)

> diff --git a/arch/arm/boot/dts/da850-evm.dts b/arch/arm/boot/dts/da850-evm.dts
> index 1f8cfdd..44f3fbc 100644
> --- a/arch/arm/boot/dts/da850-evm.dts
> +++ b/arch/arm/boot/dts/da850-evm.dts
> @@ -96,6 +96,11 @@
>   			pinctrl-0 = <&mdio_pins>;
>   			bus_freq = <2200000>;
>   		};
> +		ethernet: emac@1e20000 {

    Why label the node in the board file too?

> +			status = "okay";
> +			pinctrl-names = "default";
> +			pinctrl-0 = <&mii_pins>;
> +		};
>   	};
>   	nand_cs3@62000000 {
>   		status = "okay";
> diff --git a/arch/arm/boot/dts/da850.dtsi b/arch/arm/boot/dts/da850.dtsi
> index d5138b4..a5d30d9 100644
> --- a/arch/arm/boot/dts/da850.dtsi
> +++ b/arch/arm/boot/dts/da850.dtsi
[...]
> @@ -226,6 +242,20 @@
>   			#size-cells = <0>;
>   			reg = <0x224000 0x1000>;
>   		};
> +		ethernet: emac@1e20000 {

    I said node should be named "ethernet", not labelled. You're the second 
person that doesn't know the difference between the two. :-)

WBR, Sergei
