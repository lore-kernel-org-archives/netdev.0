From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [RFC net-next 1/4] net: phy: Export phy_stop_machine()
Date: Mon, 30 Oct 2017 14:44:21 +0100
Message-ID: <CAMuHMdWDrxOWMgYHGRc=QSaP9AN=KjqWESThmgYcs9CPHgQbLA@mail.gmail.com>
References: <20171025232124.14120-1-f.fainelli@gmail.com> <20171025232124.14120-2-f.fainelli@gmail.com>
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
Received: from mail-qt0-f194.google.com ([209.85.216.194]:55789 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752257AbdJ3NoW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 09:44:22 -0400
Received: by mail-qt0-f194.google.com with SMTP id v41so16337385qtv.12
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 06:44:22 -0700 (PDT)
In-Reply-To: <20171025232124.14120-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 1:21 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> phy_stop_machine() is publicly exported in include/linux/phy.y, and is
> not made static because it's also used by phy_device.c. Since
> phy_start_machine() is already exported, do this here too. This is a
> function that provides hard guarantees that the state machine is
> properly stopped past that synchronization point.
>
> Fixes: 00db8189d984 ("This patch adds a PHY Abstraction Layer to the Linux Kernel, enabling ethernet drivers to remain as ignorant as is reasonable of the connected PHY's design and operation details.")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert
