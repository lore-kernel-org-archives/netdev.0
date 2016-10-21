From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH 08/13] dwmac-meson8b: add support for phy selection
Date: Fri, 21 Oct 2016 17:54:08 +0200
Message-ID: <20161021155408.GR16974@lunn.ch>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1477060838-14164-9-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 21, 2016 at 04:40:33PM +0200, Neil Armstrong wrote:
> The Meson GXL dwmac Glue Layer also provides switching between an external PHY
> and an internal RMII 10/100 PHY.
> Add a way to setup the correct PHY switching from a device tree attribute.

Humm, actually. Maybe PHY_IS_INTERNAL in the phydrv->flags is the
better solution. The MAC can then use phy_is_internal(ndev->phydev) to
decide if this register needs programming.

       Andrew
