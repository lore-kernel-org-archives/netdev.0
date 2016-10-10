From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC v3 3/3] phy,leds: add support for led triggers on phy link
 state change
Date: Mon, 10 Oct 2016 02:03:32 -0700
Message-ID: <1eb3afdb-0236-65e3-64be-09cc6eeda533@gmail.com>
References: <1475874897-29720-1-git-send-email-zach.brown@ni.com>
 <1475874897-29720-4-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mlindner@marvell.com, stephen@networkplumber.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
        Larry.Finger@lwfinger.net, gregkh@linuxfoundation.org,
        rpurdie@rpsys.net, j.anaszewski@samsung.com,
        linux-leds@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: Zach Brown <zach.brown@ni.com>
Return-path: <linux-leds-owner@vger.kernel.org>
In-Reply-To: <1475874897-29720-4-git-send-email-zach.brown@ni.com>
Sender: linux-leds-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/07/2016 02:14 PM, Zach Brown wrote:
> From: Josh Cartwright <josh.cartwright@ni.com>
> 
> Create an option CONFIG_LED_TRIGGER_PHY (default n), which will
> create a set of led triggers for each instantiated PHY device.  There is
> one LED trigger per link-speed, per-phy.
> 
> This allows for a user to configure their system to allow a set of LEDs
> to represent link state changes on the phy.

Seems like we are past the RFC state now, so you might want to prefix
your patches with [PATCH ..] now. Also, the typical prefix used for
PHYLIB changes is net: phy: foo

Other than that:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Andrew, are you happy with this implementation?

[snip]

> +
> +#ifdef CONFIG_LED_TRIGGER_PHY
> +
> +#include <linux/leds.h>
> +#include <linux/phy.h>
> +
> +#define PHY_LINK_LED_MAX_TRIGGERS	5
> +#define PHY_LED_TRIGGER_SPEED_SUFFIX_SIZE	7
> +#define PHY_MII_BUS_ID_SIZE	(20 - 3)

This particular constant may be something worth moving to
include/linux/phy.h eventually.
-- 
Florian
