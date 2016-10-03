From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Subject: Re: [PATCH v4 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Mon, 3 Oct 2016 12:50:45 +0530
Message-ID: <20161003072043.GA24259@microsemi.com>
References: <1475062449-22168-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20160928161653.GA25553@lunn.ch>
Reply-To: <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160928161653.GA25553-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Thank you for code review and valuable comments.

On Wed, Sep 28, 2016 at 06:16:53PM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> > +Optional properties:
> > +- vsc8531,vddmac     : The vddmac in mV.
> > +- vsc8531,edge-slowdown      : % the edge should be slowed down relative to
> > +                       the fastest possible edge time. Native sign
> > +                       need not enter.
> > +                       Edge rate sets the drive strength of the MAC
> > +                       interface output signals.  Changing the drive
> > +                       strength will affect the edge rate of the output
> > +                       signal.  The goal of this setting is to help
> > +                       reduce electrical emission (EMI) by being able
> > +                       to reprogram drive strength and in effect slow
> > +                       down the edge rate if desired.  Table 5 shows the
> 
> Hi Raju
> 
> There is no table five here? Is that a reference to a data sheet
> table?
> 

I accepted your comment.
It was typo. It should be Table 1.
Yes. In datasheet Edge rate control is Table 5.

> > +Example:
> > +
> > +        vsc8531_0: ethernet-phy@0 {
> > +                compatible = "ethernet-phy-id0007.0570";
> > +                vsc8531,vddmac               = /bits/ 16 <MSCC_VDDMAC_3300>;
> > +                vsc8531,edge-slowdown        = /bits/ 8  <17>;
> 
> No, real values please:
> 
>                 vsc8531,vddmac          = <2000>;
>                 vsc8531,edge-slowdown   = <21>;
> 
> The driver should then do the maths to figure out the nearest magic
> value to write to the register, or complain the settings are out of
> range with an -EINVAL.
> 
> FYI: No floating point maths are allowed in the kernel.
> 

I accepted your review comment. I will change and resend again.

>    Andrew

---
Thanks,
Raju.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
