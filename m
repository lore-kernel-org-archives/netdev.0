From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v4 4/7] dt: mdio-mux: Add mdio multiplexer driver node
Date: Mon, 6 Jun 2016 11:37:50 -0700
Message-ID: <5755C2FE.1090303@gmail.com>
References: <1465216900-11755-1-git-send-email-pramod.kumar@broadcom.com>
 <1465216900-11755-5-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-arm-kernel@lists.infradead.org
To: Pramod Kumar <pramod.kumar@broadcom.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465216900-11755-5-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/06/2016 05:41 AM, Pramod Kumar wrote:
> Add integrated MDIO multiplexer driver node which contains
> two mux PCIe bus and one ethernet bus along with phys
> lying on these bus.
> 
> Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
> ---
> +		mdio_mux_iproc: mdio-mux@6602023c {
> +			compatible = "brcm,mdio-mux-iproc";
> +			reg = <0x6602023c 0x14>;
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +
> +			mdio@0 {
> +				reg = <0x0>;
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +
> +				pci_phy0: pci-phy@0 {
> +					compatible = "brcm,ns2-pcie-phy";
> +					reg = <0x0>;
> +					#phy-cells = <0>;
> +				};
> +			};
> +
> +			mdio@7 {
> +				reg = <0x7>;
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +
> +				pci_phy1: pci-phy@0 {
> +					compatible = "brcm,ns2-pcie-phy";
> +					reg = <0x0>;
> +					#phy-cells = <0>;
> +				};

Are these two PHYs always available in the NS2 SoC, or does that depend
on interfaces exposed at the board level? Should not they be flagged
with a disabled status property by default and enabled in their
respective board files?
-- 
Florian
