From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 2/7] DT: phy.txt: Add mdio-integrated-mux property
Date: Fri, 3 Jun 2016 02:46:32 +0200
Message-ID: <20160603004632.GB12165@lunn.ch>
References: <1464701801-17243-1-git-send-email-pramod.kumar@broadcom.com>
 <1464701801-17243-3-git-send-email-pramod.kumar@broadcom.com>
 <20160602232703.GA17619@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pramod Kumar <pramod.kumar@broadcom.com>,
	Mark Rutland <mark.rutland@arm.com>,
	devicetree@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	linux-kernel@vger.kernel.org,
	Kishon Vijay Abraham I <kishon@ti.com>,
	netdev@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com,
	Kumar Gala <galak@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Rob Herring <robh@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160602232703.GA17619@rob-hp-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 02, 2016 at 06:27:03PM -0500, Rob Herring wrote:
> On Tue, May 31, 2016 at 07:06:36PM +0530, Pramod Kumar wrote:
> > This property is used by integrated MDIO multiplexer
> > which has bus selection and mdio transaction generation logic,
> > integrated inside.
> > 
> > Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
> > ---
> >  Documentation/devicetree/bindings/net/mdio-mux.txt | 9 ++++++++-
> >  1 file changed, 8 insertions(+), 1 deletion(-)
> > 
> > diff --git a/Documentation/devicetree/bindings/net/mdio-mux.txt b/Documentation/devicetree/bindings/net/mdio-mux.txt
> > index 491f5bd..b5ad83e 100644
> > --- a/Documentation/devicetree/bindings/net/mdio-mux.txt
> > +++ b/Documentation/devicetree/bindings/net/mdio-mux.txt
> > @@ -5,13 +5,20 @@ numbered uniquely in a device dependent manner.  The nodes for an MDIO
> >  bus multiplexer/switch will have one child node for each child bus.
> >  
> >  Required properties:
> > -- mdio-parent-bus : phandle to the parent MDIO bus.
> >  - #address-cells = <1>;
> >  - #size-cells = <0>;
> >  
> >  Optional properties:
> > +- mdio-parent-bus : phandle to the parent MDIO bus. Should be used
> > +		if parent mdio bus is not part of multiplexer.
> 
> You don't appear to be using this. When would you?

He is moving it to optional. The mdio-mux-mmio and mdio-mux-gpio do
however use it, which follow this binding.

	Andrew
