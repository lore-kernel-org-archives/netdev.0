From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: phy: leds: Add support for "link" trigger
Date: Wed, 1 Nov 2017 13:31:02 +0100
Message-ID: <20171101123102.GF12680@lunn.ch>
References: <52ce25a6-8d6b-039d-ca08-90595eb9ee72@maciej.szmigiero.name>
 <20171101121611.GD12680@lunn.ch>
 <b789b023-2e7b-1f5b-59a6-9676db74e850@maciej.szmigiero.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
To: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b789b023-2e7b-1f5b-59a6-9676db74e850@maciej.szmigiero.name>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Yes, I did it the same way as the existing code did for phy->phy_led_triggers
> for reasons of both consistency and also to be on the safe side because
> maybe there is some non-obvious reason why it has to be freed
> explicitly (?).
 
Hi Maciej

Occasionally, there is a need to call devm_kfree(). But i don't see
anything here why it is needed. So i would drop your devm_kfree(), and
if you feel like it, add an additional patch removing the existing
one.

Thanks
	Andrew
