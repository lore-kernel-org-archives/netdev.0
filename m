From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [RFC net-next 2/4] net: smsc911x: Properly manage PHY during suspend/resume
Date: Mon, 30 Oct 2017 14:45:07 +0100
Message-ID: <CAMuHMdXSd-F=WBRytmys_T-srFQgpEh58YNUq0C1VcBjz2mdvw@mail.gmail.com>
References: <20171025232124.14120-1-f.fainelli@gmail.com> <20171025232124.14120-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, opendmb@gmail.com,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        Mason <slash.tmp@free.fr>, David Daney <david.daney@cavium.com>,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:56382 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752492AbdJ3NpJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 09:45:09 -0400
Received: by mail-qk0-f194.google.com with SMTP id l194so16115276qke.13
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 06:45:09 -0700 (PDT)
In-Reply-To: <20171025232124.14120-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 1:21 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Commit 2aa70f864955 ("net: smsc911x: Quieten netif during suspend")
> addressed the network device parts of the suspend/resume process, but
> this is not enough, we can also need to manage the PHY state machine
> during suspend.
>
> Because Geert indicated that we are going to cut the power to the block,
> we need the hard synchronization that phy_stop_machine() guarantees,
> conversely use phy_start_machine() to resume properly.
>
> There appears to be a desire to enable Wake-on-LAN, which is obviously
> dependent on the PHY not being suspend, so we don't suspend it. A future
> patch should probably add proper support for turning on/off Wake-on-LAN
> on a PHY activity/password etc. basis.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-and-tested-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert
