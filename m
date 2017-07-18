From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Tue, 18 Jul 2017 09:52:51 -0300
Message-ID: <CAOMZO5BycGHNocULcScDczRoEvbQqjnRZTDrNAw7=+zpadSOSA@mail.gmail.com>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com>
 <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com> <CAOMZO5ABD9iasv67ehcpTzcjU-iD9=8vQ2vM7Gwc4-v9pnUt-Q@mail.gmail.com>
 <f4cdcb4b-feac-5106-8068-e694dbd3b4e6@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:34944 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751371AbdGRMww (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 08:52:52 -0400
Received: by mail-ua0-f194.google.com with SMTP id 64so2383475uae.2
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 05:52:52 -0700 (PDT)
In-Reply-To: <f4cdcb4b-feac-5106-8068-e694dbd3b4e6@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 18, 2017 at 9:48 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 07/18/2017 03:39 PM, Fabio Estevam wrote:
>
>>>    Won't this result in kernel WARNING when GPIO is disabled?
>
>
>    GPIO support, I was going to type...
>
>> Not sure if I understood your point, but gpiod_set_value_cansleep() is
>> a no-op when the gpiod is NULL.
>
>
>    Look at the stub in <linux/gpio/consumer.h>, it has WARN_ON(1).

This patch does not alter the behavior of the driver with respect to
GPIO being disabled, so I still do not understand your concern.

Please be more specific.
