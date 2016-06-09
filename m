From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: Re: [PATCH 1/2] NET: PHY: Add PHY LED control binding.
Date: Thu, 09 Jun 2016 08:06:12 +0200
Message-ID: <3869397.kzojzy3Xzu@ws-stein>
References: <1465163150-21429-1-git-send-email-hauke@hauke-m.de> <1465163150-21429-2-git-send-email-hauke@hauke-m.de> <20160608193008.GA20738@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Hauke Mehrtens <hauke@hauke-m.de>, f.fainelli@gmail.com,
	netdev@vger.kernel.org, andrew@lunn.ch, john@phrozen.org,
	openwrt@kresin.me, hauke.mehrtens@intel.com,
	daniel.schwierzeck@gmail.com, eckert.florian@googlemail.com,
	devicetree@vger.kernel.org, thomas.langer@intel.com
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webbox1416.server-home.net ([77.236.96.61]:54993 "EHLO
	webbox1416.server-home.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932424AbcFIGGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 02:06:19 -0400
In-Reply-To: <20160608193008.GA20738@rob-hp-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 08 June 2016 14:30:08, Rob Herring wrote:
> > diff --git a/Documentation/devicetree/bindings/phy/phy-leds.txt
> > b/Documentation/devicetree/bindings/phy/phy-leds.txt new file mode 100644
> > index 0000000..1a35e3d
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/phy/phy-leds.txt
> > @@ -0,0 +1,52 @@
> > +LED configuration for Ethernet phys
> > +
> > +All these properties are optional, not all properties are supported by
> > +all PHYs. When more then one property name is define for one LED the
> > +order they get applied is device depended.
> > +Property names:
> > +	led-const-on: conditions the LED should be constant on
> > +	led-pulse: condition the LED should be pulsed on
> > +	led-blink-slow: condition the LED should slowly blink
> 
> How slow is slow?

This depends on the MMD.INTERNAL.LEDCH.SBF setting which is 2 Hz by default.

> > +	led-blink-fast: condition the LED should fast blink
> 
> How fast is fast?

This depends on the MMD.INTERNAL.LEDCH.FBF setting which is 16 Hz by default.

Both can be set independently to 2, 4, 8 or 16 Hz.

Best regards,
Alexander
