From: Shaohui Xie <shaohui.xie-3arQi8VN3Tc@public.gmane.org>
Subject: RE: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
Date: Fri, 15 Jan 2016 04:01:19 +0000
Message-ID: <VI1PR04MB166491DEBB439EB72742201DE8CD0@VI1PR04MB1664.eurprd04.prod.outlook.com>
References: <1452759839-9874-1-git-send-email-shh.xie@gmail.com>
 <20160114164418.GD19773@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Shaohui Xie <Shaohui.Xie-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
	"shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160114164418.GD19773-g2DYL2Zd6BY@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew-g2DYL2Zd6BY@public.gmane.org]
> Sent: Friday, January 15, 2016 12:44 AM
> To: shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
> Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linuxppc-
> dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org; f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; Shaohui Xie
> Subject: Re: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
> 
> On Thu, Jan 14, 2016 at 04:23:59PM +0800, shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
> > From: Shaohui Xie <Shaohui.Xie-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> >
> > This commit adds necessary definitions for the PHY layer to recognize
> > backplane Ethernet 1000BASE-KX and 10GBASE-KR as valid PHY interfaces,
> > "1000base-kx" for 1000BASE-KX, "10gbase-kr" for 10GBASE-KR.
> >
> > Signed-off-by: Shaohui Xie <Shaohui.Xie-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> > ---
> > changes in v2:
> > new patch.
> >
> >  Documentation/devicetree/bindings/net/ethernet.txt | 4 ++--
> >  include/linux/phy.h                                | 6 ++++++
> >  2 files changed, 8 insertions(+), 2 deletions(-)
> >
> > diff --git a/Documentation/devicetree/bindings/net/ethernet.txt
> > b/Documentation/devicetree/bindings/net/ethernet.txt
> > index 5d88f37..1166a5c 100644
> > --- a/Documentation/devicetree/bindings/net/ethernet.txt
> > +++ b/Documentation/devicetree/bindings/net/ethernet.txt
> > @@ -11,8 +11,8 @@ The following properties are common to the Ethernet
> controllers:
> >    the maximum frame size (there's contradiction in ePAPR).
> >  - phy-mode: string, operation mode of the PHY interface; supported values are
> >    "mii", "gmii", "sgmii", "qsgmii", "tbi", "rev-mii", "rmii",
> > "rgmii", "rgmii-id",
> > -  "rgmii-rxid", "rgmii-txid", "rtbi", "smii", "xgmii"; this is now a
> > de-facto
> > -  standard property;
> > +  "rgmii-rxid", "rgmii-txid", "rtbi", "smii", "xgmii", "1000base-kx",
> > + "10gbase-kr";  this is now a de-facto standard property;
> 
> I know very little about this, so i'm just asking a question. None of the other
> interface modes contain a bit rate. So is the bit rate needed for your two new
> modes?
> 
> With a bit of googling, K means copper backplane, X means 4B/5B and R means
> 64B/66B. Could there be a 10Gbps KX? a 1GBps KR? Do we actually need the speed
> here, or is kx and kr sufficient?
Hello Andrew,

1000BASE-KX and 10GBASE-KR are terms in IEEE802.3, so as XGMII and GMII. 
There are interfaces could be different bit rates but same types, 
e.g. 100BASE-LX10 and 1000BASE-LX10, or 40GBASE-KR4 and 100GBASE-KR4, 
having bit rate is clear to represent hardware.

Thank you!

 Shaohui
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
