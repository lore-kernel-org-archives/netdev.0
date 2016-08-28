From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH v2 1/4] net: dt-bindings: Document the new Meson8b and
 GXBB DWMAC bindings
Date: Sun, 28 Aug 2016 18:15:31 +0200
Message-ID: <CAFBinCDnHGf=wgvm9KzYQsf=kCrOUeO3bnEwdGy_OK-wgWkDug@mail.gmail.com>
References: <20160815164100.27766-1-martin.blumenstingl@googlemail.com>
 <7308700.atIMKyMFZU@wuerfel> <CAFBinCA0HWHR3UbVX-_wU14W0-KOr-BAf5Nyn1ocZdnYxojn2Q@mail.gmail.com>
 <4041259.IszN4229Cj@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        catalin.marinas-5wv7dgnIgG8@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org, mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org, carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4041259.IszN4229Cj@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 22, 2016 at 5:25 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> It really depends on the kind of SoC. Some may have a suboptimal
> binding, on some others there may be a distinct register area that
> just contains a few additional registers for the dwmac.
the dwmac PHY configuration registers (2x32bit) on the GXBB SoC are
part of the "periphs" region/module. This is already defined as
"simple-bus" in meson-gxbb.dtsi, see [0]
On Meson8b this is slightly different: there is no specific "periphs"
region - there the dwmac PHY configuration registers are directly
located in the cbus region at a slightly different offset than on the
GXBB SoCs.

In the future we might need a third memory region because the latest
reference kernel contains some more PHY configuration registers on
newer SoCs (GXL = S905X).

Please let me know if you're OK with the dts definition in it's
current state - or let me know how you would like to change it.

PS: I will re-send the patches in a v3 in a few minutes because that
fixes a bug during module unload.


Regards,
Martin


[0] https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi#n217
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
