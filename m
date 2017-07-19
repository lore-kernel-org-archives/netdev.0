From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Wed, 19 Jul 2017 19:37:09 -0300
Message-ID: <CAOMZO5DT9xrGzX1SPGpLxOBB_KKKt_7obtq8kWxy4AeNdDKBfg@mail.gmail.com>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
 <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com> <CAOMZO5ABD9iasv67ehcpTzcjU-iD9=8vQ2vM7Gwc4-v9pnUt-Q@mail.gmail.com>
 <f4cdcb4b-feac-5106-8068-e694dbd3b4e6@cogentembedded.com> <CAOMZO5BycGHNocULcScDczRoEvbQqjnRZTDrNAw7=+zpadSOSA@mail.gmail.com>
 <20170718133209.GB32757@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linus Walleij <linus.walleij@linaro.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:33726 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932518AbdGSWhK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 18:37:10 -0400
Received: by mail-ua0-f194.google.com with SMTP id u4so1223237uaa.0
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 15:37:10 -0700 (PDT)
In-Reply-To: <20170718133209.GB32757@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Tue, Jul 18, 2017 at 10:32 AM, Andrew Lunn <andrew@lunn.ch> wrote:

> http://elixir.free-electrons.com/linux/latest/source/include/linux/gpio/consumer.h#L345
> static inline void gpiod_set_value_cansleep(struct gpio_desc *desc, int value)
> {
>         /* GPIO can never have been requested */
>         WARN_ON(1);
> }
>
> But i would say this is a gpio problem. If GPIO enabled does not care,
> GPIO disabled should also not care.

Agreed.

Sergei, sorry for taking so long to understand your point.

> Adding Linus Walleij.

Just sent a RFC patch to linux-gpio.

Thanks
