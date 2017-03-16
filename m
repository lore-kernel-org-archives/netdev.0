From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: Re: [PATCH v2 06/23] MAINTAINERS: Add file patterns for dsa device
 tree bindings
Date: Thu, 16 Mar 2017 13:58:54 +0100
Message-ID: <CAMuHMdWVTzYjmRCduVWxB4ZWZJSYXZQcaQR6goyUvrn_zD0fRA@mail.gmail.com>
References: <1489324627-19126-1-git-send-email-geert@linux-m68k.org>
 <1489324627-19126-7-git-send-email-geert@linux-m68k.org> <20170312170407.GJ15842@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170312170407.GJ15842-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On Sun, Mar 12, 2017 at 6:04 PM, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org> wrote:
> On Sun, Mar 12, 2017 at 02:16:50PM +0100, Geert Uytterhoeven wrote:
>> Submitters of device tree binding documentation may forget to CC
>> the subsystem maintainer if this is missing.
>
>> diff --git a/MAINTAINERS b/MAINTAINERS
>> index ce461fefec6c9463..c0822d4fa5c3ade5 100644
>> --- a/MAINTAINERS
>> +++ b/MAINTAINERS
>> @@ -7812,6 +7812,7 @@ M:      Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
>>  M:   Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>
>>  L:   netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>  S:   Maintained
>> +F:   Documentation/devicetree/bindings/net/dsa/
>>  F:   drivers/net/dsa/mv88e6xxx/
>>  F:   Documentation/devicetree/bindings/net/dsa/marvell.txt
>
> If i'm reading this patch correctly, you are putting it under
>
> MARVELL 88E6XXX ETHERNET SWITCH FABRIC DRIVER
> M:      Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
> M:      Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>
> L:      netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> S:      Maintained
> F:      drivers/net/dsa/mv88e6xxx/
> F:      Documentation/devicetree/bindings/net/dsa/marvell.txt
>
> I would says the correct place for
> Documentation/devicetree/bindings/net/dsa/ is
>
> NETWORKING [DSA]
> M:      Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
> M:      Vivien Didelot <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>
> M:      Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks, that would indeed be better. Seems that entry didn't exist yet in v4.6,
when I did the original version of the patch.

Will send an update...

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
