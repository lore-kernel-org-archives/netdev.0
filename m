From: Juergen Borleis <jbe@pengutronix.de>
Subject: [PATCHv2] net: dsa: add SMSC/Microchip LAN9303 three port ethernet switch driver
Date: Fri,  7 Apr 2017 10:14:58 +0200
Message-ID: <20170407081502.30172-1-jbe@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
        kernel@pengutronix.de, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The LAN9303 is a three port 10/100 ethernet switch with integrated phys
for the two external ethernet ports. The third port is an RMII/MII
interface to a host master network interface (e.g. fixed link).

While the LAN9303 device itself supports offload packet processing, this
driver does not make use of it yet. This driver just configures the device
to provide two separate network interfaces (which is the default state of
a DSA device).

Please note: the "MDIO managed mode" driver part isn't tested yet. I have
used and tested the "I2C managed mode" only.

Changes in v2:

- code moved to 'drivers/net/dsa'
- timeouts in completion wait loops
- macros instead of various magic numbers
- development code removed
- devicetree property names changed
- devicetree example adapted
- tried to avoid to mix 'switching' and 'forwarding'...

Comments and testers especially for the MDIO part are welcome.

jb
