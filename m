From: Zach Brown <zach.brown@ni.com>
Subject: Re: [RFC v3 3/3] phy,leds: add support for led triggers on phy link
 state change
Date: Wed, 12 Oct 2016 10:57:58 -0500
Message-ID: <20161012155757.GA29538@zach-desktop>
References: <1475874897-29720-1-git-send-email-zach.brown@ni.com>
 <1475874897-29720-4-git-send-email-zach.brown@ni.com>
 <1eb3afdb-0236-65e3-64be-09cc6eeda533@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <mlindner@marvell.com>, <stephen@networkplumber.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <devel@driverdev.osuosl.org>,
        <florian.c.schilhabel@googlemail.com>, <Larry.Finger@lwfinger.net>,
        <gregkh@linuxfoundation.org>, <rpurdie@rpsys.net>,
        <j.anaszewski@samsung.com>, <linux-leds@vger.kernel.org>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1eb3afdb-0236-65e3-64be-09cc6eeda533@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 10, 2016 at 02:03:32AM -0700, Florian Fainelli wrote:
> > +
> > +#ifdef CONFIG_LED_TRIGGER_PHY
> > +
> > +#include <linux/leds.h>
> > +#include <linux/phy.h>
> > +
> > +#define PHY_LINK_LED_MAX_TRIGGERS	5
> > +#define PHY_LED_TRIGGER_SPEED_SUFFIX_SIZE	7
> > +#define PHY_MII_BUS_ID_SIZE	(20 - 3)
> 
> This particular constant may be something worth moving to
> include/linux/phy.h eventually.
> -- 
> Florian

MII_BUS_ID_SIZE is defined in include/linux/phy.h but it's defined after
phy_led_triggers.h is included so phy_led_triggers.h doesn't have access.
I could move the definition of MII_BUS_ID_SIZE above the include, but that
seemed ugly. Do you have any suggestions?
