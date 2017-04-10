From: Juergen Borleis <jbe@pengutronix.de>
Subject: Re: [PATCH v2 3/4] net: dsa: LAN9303: add I2C managed mode support
Date: Mon, 10 Apr 2017 09:58:38 +0200
Message-ID: <201704100958.38939.jbe@pengutronix.de>
References: <20170407081502.30172-1-jbe@pengutronix.de> <20170407081502.30172-4-jbe@pengutronix.de> <20170407134007.GA22263@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: Andrew Lunn <andrew@lunn.ch>, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net
To: kernel@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:41719 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750957AbdDJH7Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 03:59:16 -0400
In-Reply-To: <20170407134007.GA22263@lunn.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Friday 07 April 2017 15:40:07 Andrew Lunn wrote:
> > +Optional properties:
> > +
> > +- reset-gpios: GPIO to be used to reset the whole device, always low
> > active
>
> I would avoid the always low active comment. The input to the switch
> is active low. But i've seen designs with an inverter in the reset
> path, so from the perspective of the GPIO it would be active high. The
> device tree binding allows for this, via the flags. And since you use
> the gpiod API, it should all just work.
>
> > +		ports {
> > +			#address-cells = <1>;
> > +			#size-cells = <0>;
> > +
> > +			port@0 { /* RMII fixed link to master */
> > +				reg = <0>;
> > +				label = "cpu";
> > +				ethernet = <&master>;
> > +			};
> > +
> > +			port@1 { /* external port 1 */
> > +				compatible = "ethernet-phy-ieee802.3-c22";
> > +				reg = <1>;
> > +				label = "lan1;
> > +			};
>
> These are not PHY nodes, so does this compatible string do anything?

I removed them and nothing changed.

Regards,
Juergen

-- 
Pengutronix e.K.                             | Juergen Borleis             |
Industrial Linux Solutions                   | http://www.pengutronix.de/  |
