From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 3/7] net: ethernet: bgmac: move BCMA MDIO Phy code into a
 separate file
Date: Tue, 28 Jun 2016 22:02:19 +0200
Message-ID: <20160628200219.GE16588@lunn.ch>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
 <1467142484-11161-4-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zajec5@gmail.com, davem@davemloft.net, f.fainelli@gmail.com,
	hauke@hauke-m.de, bcm-kernel-feedback-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jon Mason <jon.mason@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1467142484-11161-4-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 28, 2016 at 03:34:40PM -0400, Jon Mason wrote:
> Move the BCMA MDIO phy into a separate file, as it is very tightly
> coupled with the BCMA bus.  This will help with the upcoming BCMA
> removal from the bgmac driver.  Optimally, this should be moved into
> phy drivers, but it is too tightly coupled with the bgmac driver to
> effectively move it without more changes to the driver.

It is quite common to have the MII bus driver as a sub driver of the
MAC driver, if they are tightly coupled. The MII drivers in
drivers/net/phy are all independent of the MAC driver and use a
different space in the register sets. This does not seem the case
here, so i think the split you have made is O.K, and i don't see a
need to move it into phy.

     Andrew
