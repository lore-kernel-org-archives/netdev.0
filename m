From: Appana Durga Kedareswara Rao <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [RFC PATCH v4 1/2] Documentation: DT: net: Add Xilinx
 gmiitorgmii converter device tree binding documentation
Date: Mon, 8 Aug 2016 13:05:40 +0000
Message-ID: <C246CAC1457055469EF09E3A7AC4E11A4A5DF3AF@XAP-PVEXMBX01.xlnx.xilinx.com>
References: <1470640505-8279-1-git-send-email-appanad@xilinx.com>
 <b3813524-7531-d294-1def-628b0a28f6bb@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Michal Simek <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"Michal Simek" <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Soren Brinkmann <sorenb-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"andrew-g2DYL2Zd6BY@public.gmane.org" <andrew-g2DYL2Zd6BY@public.gmane.org>,
	Punnaiah Choudary Kalluri <punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"Anirudha Sarangi" <anirudh-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <b3813524-7531-d294-1def-628b0a28f6bb-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Michal,

> On 8.8.2016 09:15, Kedareswara rao Appana wrote:
> > Device-tree binding documentation for xilinx gmiitorgmii converter.
> >
> > Signed-off-by: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> > ---
> > Changes for v4:
> > --> Modified compatible as suggested by Rob.
> > --> Removed underscores from the converter node name as suggested by Rob.
> > Changes for v3:
> > --> None.
> > Changes for v2:
> > --> New patch.
> >
> >  .../devicetree/bindings/net/xilinx_gmii2rgmii.txt  | 38
> > ++++++++++++++++++++++
> >  1 file changed, 38 insertions(+)
> >  create mode 100644
> > Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
> >
> > diff --git
> > a/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
> > b/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
> > new file mode 100644
> > index 0000000..453680d
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
> > @@ -0,0 +1,38 @@
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
> > +This converter sits between the MAC and the external phy.
> > +MAC <==> GMII2RGMII <==> RGMII_PHY
> > +
> > +Required properties:
> > +  - compatible : Should be "xlnx,gmii-to-rgmii-1.0"
> > +  - reg : The ID number for the phy, usually a small integer
> > +  - phy-handle: Should point to the external phy device.
> > +		See ethernet.txt file in the same directory.
> > +
> > +Example:
> > +	mdio {
> > +                #address-cells = <1>;
> > +                #size-cells = <0>;
> > +		phy: ethernet-phy@0 {
> > +			......
> > +		};
> > +                gmiitorgmii: gmiitorgmii@8 {
> > +                        compatible = "xlnx,gmii-to-rgmii-1.0";
> > +                        reg = <8>;
> > +			phy-handle = <&phy>;
> > +                };
> 
> Indentation in this example is quite weird. You are mixing tabs and spaces.

Sure will fix in the next version...

Regards,
Kedar.

> 
> Thanks,
> Michal

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
