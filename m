From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC v4 07/10] dt-bindings: net: add binding for QCA7000
 UART
Date: Mon, 3 Apr 2017 08:23:23 -0500
Message-ID: <20170403132323.vugelfs2pz3p5p6h@rob-hp-laptop>
References: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com>
 <1490621848-24828-8-git-send-email-stefan.wahren@i2se.com>
 <CAL_Jsq+gxS4u+b+C_eWeguFR0AFKuq8Hhe9Xo_5B_5w1hxvzEg@mail.gmail.com>
 <9a094176-ebe7-d906-ca9c-967285e53b07@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>,
        Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <9a094176-ebe7-d906-ca9c-967285e53b07-eS4NqCHxEME@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 28, 2017 at 06:18:03PM +0200, Stefan Wahren wrote:
> Am 27.03.2017 um 22:30 schrieb Rob Herring:
> > On Mon, Mar 27, 2017 at 8:37 AM, Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org> wrote:
> >> This is the serdev binding for the QCA7000 UART driver (Ethernet over UART).
> >>
> >> Signed-off-by: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
> >> ---
> >>
> >> According to this binding are still some questions:
> >>
> >> Where should be the optional hardware flow control defined (at master or slave side)?
> > Probably should be in the slave side. We already have uart-has-rtscts
> > and rts/cts-gpios for the UART. Those mean we have RTS/CTS, but not
> > necessarily that we want to enable them.
> >
> > In many cases, the driver may know what it needs.
> 
> Like all the other UART settings the hardware flow control can be
> configured in the QCA7000 firmware and the driver can't detect it.
> 
> Property suggestion for the slave side:
> 
> use-rtscts

Okay.

> >> Is it okay to have two bindings (qca-qca7000-spi and qca-qca7000-uart) or should they be merged?
> > Are they mutually-exclusive or both are used at the same time?
> 
> They are mutually-exclusive because they use the same pins.
> 
> >  What
> > are the dependencies between the interfaces?
> 
> Except they uses the same pins of the QCA7000, i can't see any dependency.

I think they should be a single doc.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
