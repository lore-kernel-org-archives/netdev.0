From: Tien Hock Loh <thloh-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V4 1/1] net: ethernet: Add TSE PCS support to
 dwmac-socfpga
Date: Thu, 23 Jun 2016 00:02:31 -0700
Message-ID: <1466665351.23554.16.camel@ubuntu>
References: <1466498771-18971-1-git-send-email-thloh@altera.com>
	 <3759495.N5GR8CgQvA@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <preid-qgqNFa1JUf/o2iN0hyhwsIdd74u8MsAO@public.gmane.org>,
	<dinguyen-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<thloh85-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <cnphoon-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <3759495.N5GR8CgQvA@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

On Tue, 2016-06-21 at 11:34 +0200, Arnd Bergmann wrote:
> On Tuesday, June 21, 2016 1:46:11 AM CEST thloh-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org wrote:
> > diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> > index 72d82d6..dd10f2f 100644
> > --- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> > +++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> > @@ -17,9 +17,26 @@ Required properties:
> >  Optional properties:
> >  altr,emac-splitter: Should be the phandle to the emac splitter soft IP node if
> >  		DWMAC controller is connected emac splitter.
> > +phy-mode: The phy mode the ethernet operates in
> > +altr,sgmii_to_sgmii_converter: phandle to the TSE SGMII converter
> > +
> 
> Please use '-' instead of '_' in the property names.

Overlooked this when I were fixing v4, I'll get this fixed.

> 
> Can you explain in the patch description why you can't reference
> the converter using the normal "phy-handle" property and implement
> the converter as a phy driver?
> 

The converter isn't a PHY, but an adapter that handles data stream, and
the phandle is only used to reset the adapter in software's context,
thus it doesn't seem to be correct to implement it as a phy driver. 
Does that answer your question?
If so, do you think we need to document this in the patch description in
this case?

> 	Arnd
> 

Thanks
Tien Hock
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
