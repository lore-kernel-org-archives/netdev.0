From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] dt: bindings: Add a generic ethernet device binding
Date: Fri, 15 Jul 2016 22:42:54 +0200
Message-ID: <1788846.r3134d1VMR@wuerfel>
References: <1468405204-5845-1-git-send-email-hdegoede@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1468405204-5845-1-git-send-email-hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday, July 13, 2016 12:20:04 PM CEST Hans de Goede wrote:
> +&mmc1 {
> +       non-removable;
> +       status = "okay";
> +
> +       sdio_wifi: sdio_wifi@1 {
> +               compatible = "generic,ethernet"
> +               reg = <1>;
> +       };
> +};

For discoverable buses, we normally use a compatible property that
reflects the device ID on that bus, e.g. on PCI we have "pci1A2B:3C4D",
and I think that makes more sense than having to come up with strings
for sdio devices.

In fact, Linux completely ignores the compatible strings on those
buses (pci, usb, sdio, ...), so I think we can just do the same thing
using no compatible string at all.

	Arnd

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
