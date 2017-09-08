From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Sat, 9 Sep 2017 01:17:19 +0200
Message-ID: <CACRpkdbj-c670hKv7PoFZrCzAw2Ua1PO6=cxOdwzOg+PumKBPA@mail.gmail.com>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
 <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com> <CAOMZO5ABD9iasv67ehcpTzcjU-iD9=8vQ2vM7Gwc4-v9pnUt-Q@mail.gmail.com>
 <f4cdcb4b-feac-5106-8068-e694dbd3b4e6@cogentembedded.com> <CAOMZO5BycGHNocULcScDczRoEvbQqjnRZTDrNAw7=+zpadSOSA@mail.gmail.com>
 <20170718133209.GB32757@lunn.ch> <CACRpkdYw5GWv3HRCqnWjDfctLEfzcoFdJ7ib_NVKRgw0+Y9dEg@mail.gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40B1B424@CHN-SV-EXMX02.mchp-main.com>
 <CACRpkdbK03cwzmGs=0nVeCp6NnX0-41dhEotxfDT46O4xDzagQ@mail.gmail.com> <81338659-4f46-0f2f-13c3-135b3ac876d7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Woojung.Huh@microchip.com, Andrew Lunn <andrew@lunn.ch>,
        Fabio Estevam <festevam@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34417 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752999AbdIHXRU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 19:17:20 -0400
Received: by mail-oi0-f43.google.com with SMTP id l74so18248253oih.1
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 16:17:20 -0700 (PDT)
In-Reply-To: <81338659-4f46-0f2f-13c3-135b3ac876d7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 7, 2017 at 11:39 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:

> I think it means CONFIG_GPIOLIB=n in the kernel because it's not needed,
> yet you run code (like drivers/net/phy/mdio_bus.c) that unconditionally
> calls into GPIOLIB and attempts to configure a given GPIO if available.
> This thread is actually what prompted me to write this email:

Yeah I think GPIOLIB should simply be selected in KConfig then.

Sent an inline patch to do that in the other reply.

Maybe I should simply delete the stubs if they confuse
people.

It is possible to select GPIOLIB on any platform these days
and get the right APIs, this used to not be the case but I fixed
it a while back.

Alternatively we can depend on GPIOLIB but it's simpler to just
select it I think, it's like a library this code uses and so that's
it.

Yours,
Linus Walleij
