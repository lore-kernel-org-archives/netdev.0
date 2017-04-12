From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv4] net: dsa: add SMSC/Microchip LAN9303 three port
 ethernet switch driver
Date: Wed, 12 Apr 2017 16:46:16 +0200
Message-ID: <20170412144616.GC7023@lunn.ch>
References: <20170412140218.1076-1-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170412140218.1076-1-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2017 at 04:02:14PM +0200, Juergen Borleis wrote:
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
> 
> Changes in v4:
> 
> - rebased on net-next, 'net/dsa/tag_lan9303.c' adapted to new API

Thanks for this last change.

I would say this driver is now ready for acceptance.

Thanks
	Andrew
