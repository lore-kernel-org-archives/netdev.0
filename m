From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Tue, 18 Jul 2017 09:39:48 -0300
Message-ID: <CAOMZO5ABD9iasv67ehcpTzcjU-iD9=8vQ2vM7Gwc4-v9pnUt-Q@mail.gmail.com>
References: <1500325749-8382-1-git-send-email-festevam@gmail.com> <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Fabio Estevam <fabio.estevam@nxp.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:35389 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751336AbdGRMjt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 08:39:49 -0400
Received: by mail-ua0-f173.google.com with SMTP id 64so21576146uae.2
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 05:39:49 -0700 (PDT)
In-Reply-To: <6f984a9c-e6d3-fd0a-6719-fa9032d43d1d@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 18, 2017 at 6:56 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:

>    Won't this result in kernel WARNING when GPIO is disabled?

Not sure if I understood your point, but gpiod_set_value_cansleep() is
a no-op when the gpiod is NULL.
