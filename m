From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: RE: [PATCH v2 7/7] phy: Add Northstar2 PCI Phy support
Date: Fri, 3 Jun 2016 16:53:51 +0530
Message-ID: <a8b5b6ef2c80b534eca1812caeacde57@mail.gmail.com>
References: <1464701801-17243-1-git-send-email-pramod.kumar@broadcom.com>
 <1464701801-17243-8-git-send-email-pramod.kumar@broadcom.com> <20160601131228.GF31982@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	devicetree@vger.kernel.org, Jon Mason <jonmason@broadcom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160601131228.GF31982@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: 01 June 2016 18:42
> To: Pramod Kumar
> Cc: Rob Herring; Pawel Moll; Mark Rutland; Ian Campbell; Kumar Gala;
Catalin
> Marinas; Will Deacon; Kishon Vijay Abraham I; David S. Miller;
> devicetree@vger.kernel.org; Jon Mason; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; bcm-kernel-feedback-list@broadcom.com;
linux-arm-
> kernel@lists.infradead.org
> Subject: Re: [PATCH v2 7/7] phy: Add Northstar2 PCI Phy support
>
> > +static int ns2_pci_phy_probe(struct mdio_device *mdiodev) {
> > +	struct device *dev = &mdiodev->dev;
> > +	struct phy_provider *provider;
> > +	struct ns2_pci_phy *p;
> > +	struct phy *phy;
> > +
> > +	phy = devm_phy_create(dev, dev->of_node, &ns2_pci_phy_ops);
> > +	if (IS_ERR_OR_NULL(phy)) {
> > +		dev_err(dev, "failed to create Phy\n");
> > +		return PTR_ERR(phy);
> > +	}
>
> https://www.mail-archive.com/linux-omap@vger.kernel.org/msg78030.html
>

I've explored inside this API and see it never returning NULL. I'll
replace IS_ERR_OR_NULL to IS_ERR.
Thanks for pointing this out.

> 	Andrew

Regards,
Pramod
