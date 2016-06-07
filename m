From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: RE: [PATCH v4 3/7] binding: mdio-mux: Add DT binding doc for Broadcom
 MDIO bus multiplexer
Date: Tue, 7 Jun 2016 17:27:29 +0530
Message-ID: <f6cd5df22ef8ea070d7b35e628b6d25a@mail.gmail.com>
References: <1465216900-11755-1-git-send-email-pramod.kumar@broadcom.com>
 <1465216900-11755-4-git-send-email-pramod.kumar@broadcom.com>
 <5755C290.2020704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>, Rob Herring <robh+dt@kernel.org>,
 Pawel Moll <pawel.moll@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>, Kumar Gala <galak@codeaurora.org>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>,
 Kishon Vijay Abraham I <kishon@ti.com>, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <5755C290.2020704@gmail.com>
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

Hi Florian,

> -----Original Message-----
> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> Sent: 07 June 2016 00:06
> To: Pramod Kumar; Rob Herring; Pawel Moll; Mark Rutland; Ian Campbell;
> Kumar Gala; Catalin Marinas; Will Deacon; Kishon Vijay Abraham I; David S.
> Miller
> Cc: devicetree@vger.kernel.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; bcm-kernel-feedback-list@broadcom.com; linux-arm-
> kernel@lists.infradead.org
> Subject: Re: [PATCH v4 3/7] binding: mdio-mux: Add DT binding doc for
> Broadcom MDIO bus multiplexer
>
> On 06/06/2016 05:41 AM, Pramod Kumar wrote:
> > Add DT binding doc for Broadcom MDIO bus multiplexer driver.
> >
> > Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> > Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>
>
> > +for example:
> > +		mdio_mux_iproc: mdio-mux@6602023c {
>
> I think Rob wanted you to drop the underscores here in favor of dashes,
> there
> are more below, not critical imho.
>

I'd changed node name in favor of dashes. I don't think Label could be
written with hyphens,"-".  "-" in label provides DT parsing error.


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
>
>
> --
> Florian

Regards,
Pramod
