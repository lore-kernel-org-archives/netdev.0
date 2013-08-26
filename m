From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 2/2] ARM: at91/dt: define phy available on sama5d3
 mother board
Date: Mon, 26 Aug 2013 17:21:12 +0400
Message-ID: <521B5648.3020608@cogentembedded.com>
References: <1377520431-21807-1-git-send-email-b.brezillon@overkiz.com> <1377520540-21884-1-git-send-email-b.brezillon@overkiz.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Russell King <linux@arm.linux.org.uk>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Boris BREZILLON <b.brezillon@overkiz.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377520540-21884-1-git-send-email-b.brezillon@overkiz.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 26-08-2013 16:35, Boris BREZILLON wrote:

> This patch describe the phy used on atmel sama5d3 mother board:
>   - phy address
>   - phy interrupt pin

> Signed-off-by: Boris BREZILLON <b.brezillon@overkiz.com>
> ---
>   arch/arm/boot/dts/sama5d3xmb.dtsi |    8 ++++++++
>   1 file changed, 8 insertions(+)

> diff --git a/arch/arm/boot/dts/sama5d3xmb.dtsi b/arch/arm/boot/dts/sama5d3xmb.dtsi
> index 8a9e05d..e9521d5 100644
> --- a/arch/arm/boot/dts/sama5d3xmb.dtsi
> +++ b/arch/arm/boot/dts/sama5d3xmb.dtsi
> @@ -81,6 +81,14 @@
>
>   			macb1: ethernet@f802c000 {
>   				phy-mode = "rmii";
> +
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +				phy0: ethernet-phy@0 {

    Address part of the node name doesn't match the "reg" property.

> +					interrupt-parent = <&pioE>;
> +					interrupts = <30 IRQ_TYPE_EDGE_FALLING>;
> +					reg = <1>;
> +				};

WBR, Sergei
