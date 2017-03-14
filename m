From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 1/4] dt-bindings: net: dsa: add Mediatek MT7530
 binding
Date: Tue, 14 Mar 2017 14:06:35 +0800
Message-ID: <1489471595.1870.12.camel@mtkswgap22>
References: <1489421488-300-1-git-send-email-sean.wang@mediatek.com>
         <1489421488-300-2-git-send-email-sean.wang@mediatek.com>
         <20170313163624.GD3953@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <mark.rutland-5wv7dgnIgG8@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        <Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, <keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        <objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170313163624.GD3953-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-03-13 at 17:36 +0100, Andrew Lunn wrote:
> > +- mediatek,reset-pin: Phandle to the pinctrl node used for the reset. Which
> > +	must be required if the property mediatek,mcm of specified as
> > +	"disabled". See
> > +	Documentation/devicetree/bindings/pinctrl/pinctrl-mt65xx.txt for
> > +	the mediatek pintcrl setting for the details.
> 
> Hi Sean
> 
> This appears to be a plan GPIO line. Marvell has the same. It would be
> nice to be consistent with the naming. From
> Documentation/devicetree/bindings/net/dsa/marvell.txt
> 
> Optional properties:
> 
> - reset-gpios           : Should be a gpio specifier for a reset line
> 
>   Andrew


Hi Andrew,

I'll change the property into the consistent way, and usage for 

GPIO control be also used in devm_gpiod_* instead as you suggested

for patch 4.

	Sean

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
