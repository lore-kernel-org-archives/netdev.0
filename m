From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [net-next PATCH v1 1/2] net: dt-bindings: add RGMII TX delay
 configuration to meson8b-dwmac
Date: Thu, 24 Nov 2016 17:52:20 +0100
Message-ID: <CAFBinCCc_CEm-ujR5vrBuQnoRcDMuuo+T0usQ3O5+5t5b+9UrQ@mail.gmail.com>
References: <20161124143417.10178-1-martin.blumenstingl@googlemail.com>
 <20161124143417.10178-2-martin.blumenstingl@googlemail.com> <20161124154858.GB20455@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        peppe.cavallaro-qxv4g6HH51o@public.gmane.org, carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org, jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161124154858.GB20455-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On Thu, Nov 24, 2016 at 4:48 PM, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org> wrote:
>> The configuration values are provided as preprocessor macros to make the
>> devicetree files easier to read.
>
> Hi Martin
>
> If i'm reading the code/comments correctly, you can set the delay to
> 0, 2, 4 or 6ns? So calling this property amlogic,tx-delay-ns would be
> even easier to read.
indeed, this sounds like a very nice idea (as it moves the calculation
from the programmer's brain to dwmac-meson8b.c)!

I'll send an updated version once I received enough feedback (in case
something else is wrong with the patches)
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
