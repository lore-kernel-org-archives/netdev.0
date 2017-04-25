From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] ARM: dts: Add the ethernet and ethernet PHY to the
 cygnus core DT.
Date: Tue, 25 Apr 2017 12:41:28 +0300
Message-ID: <86e911e7-ca92-af6e-8efb-812ee1939320@cogentembedded.com>
References: <20170424215022.30382-1-eric@anholt.net>
 <20170424215022.30382-3-eric@anholt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>
To: Eric Anholt <eric@anholt.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170424215022.30382-3-eric@anholt.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/25/2017 12:50 AM, Eric Anholt wrote:

> Cygnus has a single amac controller connected to the B53 switch with 2
> PHYs.  On the BCM911360_EP platform, those two PHYs are connected to
> the external ethernet jacks.
>
> Signed-off-by: Eric Anholt <eric@anholt.net>
> ---
>  arch/arm/boot/dts/bcm-cygnus.dtsi      | 60 ++++++++++++++++++++++++++++++++++
>  arch/arm/boot/dts/bcm911360_entphn.dts |  8 +++++
>  2 files changed, 68 insertions(+)
>
> diff --git a/arch/arm/boot/dts/bcm-cygnus.dtsi b/arch/arm/boot/dts/bcm-cygnus.dtsi
> index 009f1346b817..318899df9972 100644
> --- a/arch/arm/boot/dts/bcm-cygnus.dtsi
> +++ b/arch/arm/boot/dts/bcm-cygnus.dtsi
[...]
> @@ -295,6 +345,16 @@
>  			status = "disabled";
>  		};
>
> +		eth0: enet@18042000 {

    Oh, and this one should be named "ethernet", according to the DT spec.

> +			compatible = "brcm,amac";
> +			reg = <0x18042000 0x1000>,
> +			      <0x18110000 0x1000>;
> +			reg-names = "amac_base", "idm_base";
> +			interrupts = <GIC_SPI 110 IRQ_TYPE_LEVEL_HIGH>;
> +			max-speed = <1000>;
> +			status = "disabled";
> +		};
> +
>  		nand: nand@18046000 {
>  			compatible = "brcm,nand-iproc", "brcm,brcmnand-v6.1";
>  			reg = <0x18046000 0x600>, <0xf8105408 0x600>,
[...]

MBR, Sergei
