From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 3/4] bluetooth: hci_uart: add LL protocol serdev
 driver support
Date: Fri, 07 Apr 2017 15:09:18 -0500
Message-ID: <1491595758.2136.28.camel@redhat.com>
References: <20170407143516.9945-1-robh@kernel.org>
         <1491584978.2136.21.camel@redhat.com>
         <CAL_Jsq+aM+xxbu=3v8_w9Ce+=t_pXmVWuisnckA8_8LOS-ftVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Wei Xu <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>,
        Satish Patel <satish.patel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL_Jsq+aM+xxbu=3v8_w9Ce+=t_pXmVWuisnckA8_8LOS-ftVA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-04-07 at 13:48 -0500, Rob Herring wrote:
> On Fri, Apr 7, 2017 at 12:09 PM, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> wrote:
> > On Fri, 2017-04-07 at 09:35 -0500, Rob Herring wrote:
> > > Turns out that the LL protocol and the TI-ST are the same thing
> > > AFAICT.
> > > The TI-ST adds firmware loading, GPIO control, and shared access
> > > for
> > > NFC, FM radio, etc. For now, we're only implementing what is
> > > needed
> > > for
> > > BT. This mirrors other drivers like BCM and Intel, but uses the
> > > new
> > > serdev bus.
> > > 
> > > The firmware loading is greatly simplified by using existing
> > > infrastructure to send commands. It may be a bit slower than the
> > > original code using synchronous functions, but the real
> > > bottleneck is
> > > likely doing firmware load at 115.2kbps.
> > 
> > Is there no way to put the TI-specific stuff into a TI UART module
> > rather than building it into the generic one?
> 
> In case it's not clear, all of HCI_LL is the TI specific part, not
> just what I'm adding. So you are talking about putting each UART BT
> protocol into a separate module. I'd assume that is doable, but seems
> orthogonal to this patch set. I'd also assume there was some reason
> that was not done already.

Ok, thanks for the explanation.  Wasn't clear at all from the file
paths in the source tree; it looked generic.

Dan
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
