From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 4/4] net: dsa: LAN9303: add MDIO managed mode support
Date: Fri, 7 Apr 2017 17:05:14 +0200
Message-ID: <20170407150514.GE23415@lunn.ch>
References: <20170407081502.30172-1-jbe@pengutronix.de>
 <20170407081502.30172-5-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        vivien.didelot@savoirfairelinux.com, davem@davemloft.net
To: Juergen Borleis <jbe@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170407081502.30172-5-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 07, 2017 at 10:15:02AM +0200, Juergen Borleis wrote:
> When the LAN9303 device is in MDIO manged mode, all register accesses must
> be done via MDIO.
> 
> Please note: this code is *untested* yet due to the absence of such
> configured hardware. It is based on a patch of Stefan Roese from 2014.

I looked through the code and i don't see anything obviously
wrong. But so long as we get the ABI correct, we can fix everything
else later. And the ABI here is just the device tree binding. And that
is identical to the i2c binding. The properties just go in a different
place in the tree. So please do the *TODO*, you can look at other
examples, e.g. the Marvell binding documentation.

With that done, i will ACK this code.

     Andrew
