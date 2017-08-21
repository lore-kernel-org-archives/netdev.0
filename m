From: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC PATCH] dt-binding: net: sfp binding documentation
Date: Mon, 21 Aug 2017 14:12:42 -0500
Message-ID: <CAL_JsqJNeibfFVKVjdTJJ88WKonSYnXMdT5mu7V46AGPRbAKbw@mail.gmail.com>
References: <d73b635069a2054d110632f1f4196cd4bc281e7f.1503224886.git.baruch@tkos.co.il>
 <20170821125317.GS20805@n2100.armlinux.org.uk> <20170821150653.jmoogmxklkfbrzxg@sapphire.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170821150653.jmoogmxklkfbrzxg-MwjkAAnuF3khR1HGirfZ1z4kX+cae0hd@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 10:06 AM, Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org> wrote:
> Hi Russell,
>
> On Mon, Aug 21, 2017 at 01:53:17PM +0100, Russell King - ARM Linux wrote:
>> On Sun, Aug 20, 2017 at 01:28:06PM +0300, Baruch Siach wrote:
>> > Add device-tree binding documentation SFP transceivers. Support for SFP
>> > transceivers has been recently introduced (drivers/net/phy/sfp.c).
>> >
>> > Signed-off-by: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
>> > ---
>> >
>> > The SFP driver is on net-next.
>> >
>> > Not sure about the rate-select-gpio property name. The SFP+ standard
>> > (not supported yet) uses two signals, RS0 and RS1. RS0 is compatible
>> > with the SFP rate select signal, while RS1 controls the Tx rate.
>>
>> SFP+ is usable with this, but the platforms I have do not wire the
>> rate select pins on the SFP+ sockets to GPIOs, but hard-wire them.
>
> So maybe naming this signal 'rate-select0-gpio' would make it more future
> (SPF+) proof? Or 'rate-select-rx-gpio'?

Just extend it by making it an array of 2 gpios.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
