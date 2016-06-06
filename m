From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v4 3/7] binding: mdio-mux: Add DT binding doc for Broadcom
 MDIO bus multiplexer
Date: Mon, 6 Jun 2016 11:36:00 -0700
Message-ID: <5755C290.2020704@gmail.com>
References: <1465216900-11755-1-git-send-email-pramod.kumar@broadcom.com>
 <1465216900-11755-4-git-send-email-pramod.kumar@broadcom.com>
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
In-Reply-To: <1465216900-11755-4-git-send-email-pramod.kumar@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/06/2016 05:41 AM, Pramod Kumar wrote:
> Add DT binding doc for Broadcom MDIO bus multiplexer driver.
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>


> +for example:
> +		mdio_mux_iproc: mdio-mux@6602023c {

I think Rob wanted you to drop the underscores here in favor of dashes,
there are more below, not critical imho.

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


-- 
Florian
