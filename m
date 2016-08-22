From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v2 1/4] net: dt-bindings: Document the new Meson8b and GXBB DWMAC bindings
Date: Mon, 22 Aug 2016 13:55:22 +0200
Message-ID: <7308700.atIMKyMFZU@wuerfel>
References: <20160815164100.27766-1-martin.blumenstingl@googlemail.com> <20160820093538.9707-1-martin.blumenstingl@googlemail.com> <20160820093538.9707-2-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
        carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org, mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160820093538.9707-2-martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday, August 20, 2016 11:35:35 AM CEST Martin Blumenstingl wrote:
> +- reg: The first register range should be the one of the DWMAC
> +       controller. The second range is is for the Amlogic specific
> +       configuration (for example the PRG_ETHERNET register range
> +       on Meson8b and newer)
>  
...

> +Example for GXBB:
> +       ethmac: ethernet@c9410000 {
> +               compatible = "amlogic,meson-gxbb-dwmac", "snps,dwmac";
> +               reg = <0x0 0xc9410000 0x0 0x10000>,
> +                       <0x0 0xc8834540 0x0 0x8>;
> 

The address "0xc8834540" suggests that this is part of a larger register
range that is used for various things, i.e. a "syscon" type of device.

How about making this a syscon reference rather than a "reg" address?

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
