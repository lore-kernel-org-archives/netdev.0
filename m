From: Scott Branden <scott.branden@broadcom.com>
Subject: Re: [PATCH 7/7] ARM: dts: NSP: Add bgmac entries
Date: Fri, 8 Jul 2016 09:14:17 -0700
Message-ID: <577FD159.7000905@broadcom.com>
References: <1467993362-13229-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Scott Branden <sbranden@broadcom.com>, Pawel Moll <pawel.moll@arm.com>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>, hauke@hauke-m.de,
 zajec5@gmail.com, linux-kernel@vger.kernel.org, Ray Jui <rjui@broadcom.com>,
 Rob Herring <robh+dt@kernel.org>, bcm-kernel-feedback-list@broadcom.com,
 Kumar Gala <galak@codeaurora.org>, netdev@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: Jon Mason <jon.mason@broadcom.com>, davem@davemloft.net,
 f.fainelli@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1467993362-13229-1-git-send-email-jon.mason@broadcom.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Jon,

In Subject line, you mean add amac entries.


On 16-07-08 08:56 AM, Jon Mason wrote:
> Add device tree entries for the ethernet devices present on the
> Broadcom Northstar Plus SoCs
>
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> ---
>   arch/arm/boot/dts/bcm-nsp.dtsi   | 18 ++++++++++++++++++
>   arch/arm/boot/dts/bcm958625k.dts |  8 ++++++++
>   2 files changed, 26 insertions(+)
>
> diff --git a/arch/arm/boot/dts/bcm-nsp.dtsi b/arch/arm/boot/dts/bcm-nsp.dtsi
> index def9e78..f6d5abe 100644
> --- a/arch/arm/boot/dts/bcm-nsp.dtsi
> +++ b/arch/arm/boot/dts/bcm-nsp.dtsi
> @@ -192,6 +192,24 @@
>   			status = "disabled";
>   		};
>
> +		amac0: ethernet@22000 {
> +			compatible = "brcm,nsp-amac";
> +			reg = <0x022000 0x1000>,
> +			      <0x110000 0x1000>;
> +			reg-names = "amac_base", "idm_base";
> +			interrupts = <GIC_SPI 147 IRQ_TYPE_LEVEL_HIGH>;
> +			status = "disabled";
> +		};
> +
> +		amac1: ethernet@23000 {
> +			compatible = "brcm,nsp-amac";
> +			reg = <0x023000 0x1000>,
> +			      <0x111000 0x1000>;
> +			reg-names = "amac_base", "idm_base";
> +			interrupts = <GIC_SPI 148 IRQ_TYPE_LEVEL_HIGH>;
> +			status = "disabled";
> +		};
> +
>   		nand: nand@26000 {
>   			compatible = "brcm,nand-iproc", "brcm,brcmnand-v6.1";
>   			reg = <0x026000 0x600>,
> diff --git a/arch/arm/boot/dts/bcm958625k.dts b/arch/arm/boot/dts/bcm958625k.dts
> index e298450..f41a13b 100644
> --- a/arch/arm/boot/dts/bcm958625k.dts
> +++ b/arch/arm/boot/dts/bcm958625k.dts
> @@ -56,6 +56,14 @@
>   	status = "okay";
>   };
>
> +&amac0 {
> +	status = "okay";
> +};
> +
> +&amac1 {
> +	status = "okay";
> +};
> +
>   &pcie0 {
>   	status = "okay";
>   };
>

Regards,
  Scott
