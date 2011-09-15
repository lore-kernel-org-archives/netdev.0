From: David Daney <david.s.daney@gmail.com>
Subject: Re: [PATCH 2/3] netdev/of/phy: Add MDIO bus multiplexer support.
Date: Wed, 14 Sep 2011 21:16:10 -0700
Message-ID: <4E717C0A.5050905@gmail.com>
References: <1314820906-14004-1-git-send-email-david.daney@cavium.com>        <1314820906-14004-3-git-send-email-david.daney@cavium.com> <CACxGe6tA6D9JVf0_K-JAGnKcQmDmD=1ytqqYb6or-KjP9uZNxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Daney <david.daney@cavium.com>,
	David Daney <ddaney@caviumnetworks.com>,
	linux-mips@linux-mips.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, ralf@linux-mips.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACxGe6tA6D9JVf0_K-JAGnKcQmDmD=1ytqqYb6or-KjP9uZNxg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/14/2011 05:51 PM, Grant Likely wrote:
>
>
> On Aug 31, 2011 2:01 PM, "David Daney" <david.daney@cavium.com 
> <mailto:david.daney@cavium.com>> wrote:
> >
> > This patch adds a somewhat generic framework for MDIO bus
> > multiplexers.  It is modeled on the I2C multiplexer.
> >
>
[...]
>
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/mdio-mux.txt
> > @@ -0,0 +1,132 @@
> > +Common MDIO bus multiplexer/switch properties.
> > +
> > +An MDIO bus multiplexer/switch will have several child busses that are
> > +numbered uniquely in a device dependent manner.  The nodes for an MDIO
> > +bus multiplexer/switch will have one child node for each child bus.
> > +
> > +Required properties:
> > +- parent-bus : phandle to the parent MDIO bus.
>
> As discussed, I like mdio-parent-bus.
>
> > +
> > +Optional properties:
> > +- Other properties specific to the multiplexer/switch hardware.
> > +
> > +Required properties for child nodes:
> > +- #address-cells = <1>;
> > +- #size-cells = <0>;
> > +- cell-index : The sub-bus number.
>
> Use reg, not cell-index. That is what it is there for. And add the 
> appropriate #address/size-cells in the parent.
>
> I've not reviewed the implementation, but with the changes. I'm okay 
> with the binding.
>

Thanks for the prompt reply Grant.

I will rework this with the binding changes and send a new version soon.

David Daney
