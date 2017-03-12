From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v2 06/23] MAINTAINERS: Add file patterns for dsa device
 tree bindings
Date: Sun, 12 Mar 2017 18:04:07 +0100
Message-ID: <20170312170407.GJ15842@lunn.ch>
References: <1489324627-19126-1-git-send-email-geert@linux-m68k.org>
 <1489324627-19126-7-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1489324627-19126-7-git-send-email-geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 12, 2017 at 02:16:50PM +0100, Geert Uytterhoeven wrote:
> Submitters of device tree binding documentation may forget to CC
> the subsystem maintainer if this is missing.

> diff --git a/MAINTAINERS b/MAINTAINERS
> index ce461fefec6c9463..c0822d4fa5c3ade5 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -7812,6 +7812,7 @@ M:	Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
>  M:	Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>
>  L:	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>  S:	Maintained
> +F:	Documentation/devicetree/bindings/net/dsa/
>  F:	drivers/net/dsa/mv88e6xxx/
>  F:	Documentation/devicetree/bindings/net/dsa/marvell.txt

Hi Geert

If i'm reading this patch correctly, you are putting it under

MARVELL 88E6XXX ETHERNET SWITCH FABRIC DRIVER
M:      Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
M:      Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>
L:      netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
S:      Maintained
F:      drivers/net/dsa/mv88e6xxx/
F:      Documentation/devicetree/bindings/net/dsa/marvell.txt

I would says the correct place for
Documentation/devicetree/bindings/net/dsa/ is

NETWORKING [DSA]
M:      Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
M:      Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>
M:      Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
S:      Maintained
F:      net/dsa/
F:      include/net/dsa.h
F:      drivers/net/dsa/

	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
