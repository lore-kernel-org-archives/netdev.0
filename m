From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4] net: dsa: add SMSC/Microchip LAN9303 three port
 ethernet switch driver
Date: Wed, 12 Apr 2017 12:04:46 -0400 (EDT)
Message-ID: <20170412.120446.1436199142955903765.davem@davemloft.net>
References: <20170412140218.1076-1-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: jbe@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170412140218.1076-1-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Juergen Borleis <jbe@pengutronix.de>
Date: Wed, 12 Apr 2017 16:02:14 +0200

> The LAN9303 is a three port 10/100 ethernet switch with integrated phys
> for the two external ethernet ports. The third port is an RMII/MII
> interface to a host master network interface (e.g. fixed link).
> 
> While the LAN9303 device itself supports offload packet processing, this
> driver does not make use of it yet. This driver just configures the device
> to provide two separate network interfaces (which is the default state of
> a DSA device).
> 
> Please note: the "MDIO managed mode" driver part isn't tested yet. I have
> used and tested the "I2C managed mode" only.

Series applied, thank you.
