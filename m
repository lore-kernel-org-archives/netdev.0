From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH 08/13] dwmac-meson8b: add support for phy selection
Date: Fri, 21 Oct 2016 17:46:34 +0200
Message-ID: <20161021154634.GQ16974@lunn.ch>
References: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
 <1477060838-14164-9-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khilman@baylibre.com, carlo@caione.org, linus.walleij@linaro.org,
        linux-gpio@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-amlogic@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50995 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934249AbcJUPrE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 11:47:04 -0400
Content-Disposition: inline
In-Reply-To: <1477060838-14164-9-git-send-email-narmstrong@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2016 at 04:40:33PM +0200, Neil Armstrong wrote:
> The Meson GXL dwmac Glue Layer also provides switching between an external PHY
> and an internal RMII 10/100 PHY.
> Add a way to setup the correct PHY switching from a device tree attribute.

Hi Neil

Can this be made automatic?

The internal PHY appears to be on address 8. Can there also be an
external PHY on address 8? Could you follow the phy-handle link to the
phy node, check the address, and if it is 8, configure for an internal
PHY?

	Andrew
