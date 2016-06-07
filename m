From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: RE: [PATCH v4 7/7] phy: Add Northstar2 PCI Phy support
Date: Tue, 7 Jun 2016 17:55:55 +0530
Message-ID: <6ed8bf6ba5de670588715d55ca42d631@mail.gmail.com>
References: <1465216900-11755-1-git-send-email-pramod.kumar@broadcom.com>
 <1465216900-11755-8-git-send-email-pramod.kumar@broadcom.com> <5755C404.3080502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jon Mason <jonmason@broadcom.com>
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
In-Reply-To: <5755C404.3080502@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

> -----Original Message-----
> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> Sent: 07 June 2016 00:12
> To: Pramod Kumar; Rob Herring; Pawel Moll; Mark Rutland; Ian Campbell;
> Kumar Gala; Catalin Marinas; Will Deacon; Kishon Vijay Abraham I; David S.
> Miller
> Cc: devicetree@vger.kernel.org; linux-arm-kernel@lists.infradead.org; bcm-
> kernel-feedback-list@broadcom.com; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org; Jon Mason
> Subject: Re: [PATCH v4 7/7] phy: Add Northstar2 PCI Phy support
>
> On 06/06/2016 05:41 AM, Pramod Kumar wrote:
> > Add PCI Phy support for Broadcom Northstar2 SoCs.  This driver uses
> > the interface from the iproc mdio mux driver to enable the devices
> > respective phys.
> >
> > Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> > Signed-off-by: Jon Mason <jonmason@broadcom.com>
> > Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
> > ---
> >  drivers/phy/Kconfig            |   8 +++
> >  drivers/phy/Makefile           |   2 +-
> >  drivers/phy/phy-bcm-ns2-pcie.c | 115
> > +++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 124 insertions(+), 1 deletion(-)  create mode 100644
> > drivers/phy/phy-bcm-ns2-pcie.c
> >
> > diff --git a/drivers/phy/Kconfig b/drivers/phy/Kconfig index
> > b869b98..01fb93b 100644
> > --- a/drivers/phy/Kconfig
> > +++ b/drivers/phy/Kconfig
> > @@ -434,4 +434,12 @@ config PHY_CYGNUS_PCIE
> >
> >  source "drivers/phy/tegra/Kconfig"
> >
> > +config PHY_NS2_PCIE
> > +	tristate "Broadcom Northstar2 PCIe PHY driver"
> > +	depends on OF && MDIO_BUS_MUX_BCM_IPROC
> > +	select GENERIC_PHY
> > +	default ARCH_BCM_IPROC
>
> Are not you missing a dependency on PHYLIB too to provide
> mdio_module_register() etc. (at least make it build)?
>

This depends on MDIO_BUS_MUX_BCM_IPROC which itself depends on PHYLIB. Hence
I don't think We need to take care of this here.

> --
> Florian

Regards,
Pramod
