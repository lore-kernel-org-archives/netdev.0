From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH 08/13] dwmac-meson8b: add support for phy selection
Date: Fri, 21 Oct 2016 18:08:07 +0200
Message-ID: <20161021160807.GT16974@lunn.ch>
References: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
 <1477060838-14164-9-git-send-email-narmstrong@baylibre.com>
 <20161021155408.GR16974@lunn.ch>
 <dc810494-6ece-c4ae-d412-ed9af3fac9c2@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khilman@baylibre.com, carlo@caione.org, linus.walleij@linaro.org,
        linux-gpio@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-amlogic@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51043 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755661AbcJUQId (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 12:08:33 -0400
Content-Disposition: inline
In-Reply-To: <dc810494-6ece-c4ae-d412-ed9af3fac9c2@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neil

> Yes this would be a good idea if we were able to scan the internal
> and external PHYs at the same time, but with our limited knowledge
> the values we write in the register seems to switch a mux for the
> whole RMII and MDIO signals to either interface.

Ah, O.K. So you need something like:

drivers/net/phy/mdio-mux-mmioreg.c

This seems to be limited to a single byte for the mux register, so you
might need to make some extensions.

      Andrew
