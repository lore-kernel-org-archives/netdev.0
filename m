From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: RE: [PATCH v4 4/7] dt: mdio-mux: Add mdio multiplexer driver node
Date: Fri, 10 Jun 2016 09:54:11 +0530
Message-ID: <0581378b82179ea816fb2f8644d3fc93@mail.gmail.com>
References: <1465216900-11755-1-git-send-email-pramod.kumar@broadcom.com>
 <1465216900-11755-5-git-send-email-pramod.kumar@broadcom.com> <5755C2FE.1090303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <f.fainelli@gmail.com>,
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
In-Reply-To: <5755C2FE.1090303@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

> -----Original Message-----
> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> Sent: 07 June 2016 00:08
> To: Pramod Kumar; Rob Herring; Pawel Moll; Mark Rutland; Ian Campbell;
> Kumar Gala; Catalin Marinas; Will Deacon; Kishon Vijay Abraham I; David S.
> Miller
> Cc: devicetree@vger.kernel.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; bcm-kernel-feedback-list@broadcom.com; linux-arm-
> kernel@lists.infradead.org
> Subject: Re: [PATCH v4 4/7] dt: mdio-mux: Add mdio multiplexer driver node
>
> On 06/06/2016 05:41 AM, Pramod Kumar wrote:
> > Add integrated MDIO multiplexer driver node which contains two mux
> > PCIe bus and one ethernet bus along with phys lying on these bus.
> >
> > Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
> > ---
> > +		mdio_mux_iproc: mdio-mux@6602023c {
> > +			compatible = "brcm,mdio-mux-iproc";
> > +			reg = <0x6602023c 0x14>;
> > +			#address-cells = <1>;
> > +			#size-cells = <0>;
> > +
> > +			mdio@0 {
> > +				reg = <0x0>;
> > +				#address-cells = <1>;
> > +				#size-cells = <0>;
> > +
> > +				pci_phy0: pci-phy@0 {
> > +					compatible = "brcm,ns2-pcie-phy";
> > +					reg = <0x0>;
> > +					#phy-cells = <0>;
> > +				};
> > +			};
> > +
> > +			mdio@7 {
> > +				reg = <0x7>;
> > +				#address-cells = <1>;
> > +				#size-cells = <0>;
> > +
> > +				pci_phy1: pci-phy@0 {
> > +					compatible = "brcm,ns2-pcie-phy";
> > +					reg = <0x0>;
> > +					#phy-cells = <0>;
> > +				};
>
> Are these two PHYs always available in the NS2 SoC, or does that depend on
> interfaces exposed at the board level? Should not they be flagged with a
> disabled status property by default and enabled in their respective board
> files?
> --

It depends on the interfaces exposed at board level. We will disable it in
dtsi and enable it dts file. I'll address this through next patch set.

> Florian

Regards,
Pramod
