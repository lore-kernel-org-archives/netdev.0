From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: RE: [PATCH v2 1/7] mdio:mux: Enhanced MDIO mux framework for
 integrated multiplexers
Date: Fri, 3 Jun 2016 19:11:44 +0530
Message-ID: <722986e44cf0e0fbb8073605c8d8dcda@mail.gmail.com>
References: <1464701801-17243-1-git-send-email-pramod.kumar@broadcom.com>
 <1464701801-17243-2-git-send-email-pramod.kumar@broadcom.com> <20160601130207.GE31982@lunn.ch>
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
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160601130207.GE31982@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: 01 June 2016 18:32
> To: Pramod Kumar
> Cc: Rob Herring; Pawel Moll; Mark Rutland; Ian Campbell; Kumar Gala;
Catalin
> Marinas; Will Deacon; Kishon Vijay Abraham I; David S. Miller;
> devicetree@vger.kernel.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; bcm-kernel-feedback-list@broadcom.com;
linux-arm-
> kernel@lists.infradead.org
> Subject: Re: [PATCH v2 1/7] mdio:mux: Enhanced MDIO mux framework for
> integrated multiplexers
>
> > diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c index
> > 8453f08..cf40e7a 100644
> > --- a/drivers/of/of_mdio.c
> > +++ b/drivers/of/of_mdio.c
> > @@ -225,6 +225,9 @@ int of_mdiobus_register(struct mii_bus *mdio,
struct
> device_node *np)
> >  	if (rc)
> >  		return rc;
> >
> > +	if (of_property_read_bool(np, "mdio-integrated-mux"))
> > +		return 0;
> > +
>
> Hi
>
> Rather than doing this, did you try setting bus->phy_mask = 0 and
calling
> mdiobus_register(), rather than of_mdiobus_regsiter() for the parent
bus?
>

After setting bus->phy_mask = ~0 and using mdiobus_regsiter() I could get
rid of newly added
Property. It works for me as I find same has been done inside of
of_mdiobus_regsiter().

Thanks for pointing out this.

> 	Andrew
