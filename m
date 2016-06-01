From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 7/7] phy: Add Northstar2 PCI Phy support
Date: Wed, 1 Jun 2016 15:12:28 +0200
Message-ID: <20160601131228.GF31982@lunn.ch>
References: <1464701801-17243-1-git-send-email-pramod.kumar@broadcom.com>
 <1464701801-17243-8-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Pramod Kumar <pramod.kumar@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55467 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758419AbcFANMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2016 09:12:39 -0400
Content-Disposition: inline
In-Reply-To: <1464701801-17243-8-git-send-email-pramod.kumar@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int ns2_pci_phy_probe(struct mdio_device *mdiodev)
> +{
> +	struct device *dev = &mdiodev->dev;
> +	struct phy_provider *provider;
> +	struct ns2_pci_phy *p;
> +	struct phy *phy;
> +
> +	phy = devm_phy_create(dev, dev->of_node, &ns2_pci_phy_ops);
> +	if (IS_ERR_OR_NULL(phy)) {
> +		dev_err(dev, "failed to create Phy\n");
> +		return PTR_ERR(phy);
> +	}

https://www.mail-archive.com/linux-omap@vger.kernel.org/msg78030.html

	Andrew
