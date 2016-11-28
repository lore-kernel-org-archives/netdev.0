From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 0/7] stmmac: dwmac-meson8b: configurable RGMII TX
 delay
Date: Sun, 27 Nov 2016 20:33:24 -0500 (EST)
Message-ID: <20161127.203324.1634866862730391239.davem@davemloft.net>
References: <20161124143417.10178-1-martin.blumenstingl@googlemail.com>
        <20161125130156.17879-1-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161125130156.17879-1-martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date: Fri, 25 Nov 2016 14:01:49 +0100

> Currently the dwmac-meson8b stmmac glue driver uses a hardcoded 1/4
> cycle TX clock delay. This seems to work fine for many boards (for
> example Odroid-C2 or Amlogic's reference boards) but there are some
> others where TX traffic is simply broken.
> There are probably multiple reasons why it's working on some boards
> while it's broken on others:
> - some of Amlogic's reference boards are using a Micrel PHY
> - hardware circuit design
> - maybe more...

The ARM arch file changes do not apply cleanly to net-next, you probably
want to merge them via the ARM tree instead of mine, and respin this series
to be without the .dts file changes.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
