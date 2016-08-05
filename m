From: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Subject: RE: [RFC PATCH v3 1/2] Documentation: DT: net: Add Xilinx
 gmiitorgmii converter device tree binding documentation
Date: Fri, 5 Aug 2016 06:48:51 +0000
Message-ID: <C246CAC1457055469EF09E3A7AC4E11A4A5DD373@XAP-PVEXMBX01.xlnx.xilinx.com>
References: <1470312789-28275-1-git-send-email-appanad@xilinx.com>
 <20160804182515.GA19890@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "mark.rutland@arm.com" <mark.rutland@arm.com>,
	Michal Simek <michals@xilinx.com>,
	Soren Brinkmann <sorenb@xilinx.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
	"Anirudha Sarangi" <anirudh@xilinx.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rob Herring <robh@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160804182515.GA19890@rob-hp-laptop>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rob,

	Thanks for the review...

<Snip>

> > +XILINX GMIITORGMII Converter Driver Device Tree Bindings
> > +--------------------------------------------------------
> > +
> > +The Gigabit Media Independent Interface (GMII) to Reduced Gigabit
> > +Media Independent Interface (RGMII) core provides the RGMII between
> > +RGMII-compliant Ethernet physical media devices (PHY) and the Gigabit
> Ethernet controller.
> > +This core can be used in all three modes of operation(10/100/1000 Mb/s).
> > +The Management Data Input/Output (MDIO) interface is used to
> > +configure the Speed of operation. This core can switch dynamically
> > +between the three Different speed modes by configuring the conveter
> register through mdio write.
> > +
> > +The MDIO is a bus to which the PHY devices are connected.  For each
> > +device that exists on this bus, a child node should be created.  See
> > +the definition of the PHY node in booting-without-of.txt for an
> > +example of how to define a PHY.
> > +
> > +Required properties:
> > +  - compatible : Should be "xilinx,gmiitorgmii"
> 
> Perhaps xilinx,gmii-to-rgmii.

Sure...

> 
> This needs some sort of version information in the compatible string.

Sure will fix in the next version...

> 
> > +  - reg : The ID number for the phy, usually a small integer
> > +
> > +Example:
> > +	mdio {
> > +                #address-cells = <1>;
> > +                #size-cells = <0>;
> > +		ethernet-phy@0 {
> > +			......
> > +		};
> > +                gmii_to_rgmii: gmii_to_rgmii@8 {
> 
> Don't use underscores in node names.

Ok will fix in the next version...

Regards,
Kedar.
