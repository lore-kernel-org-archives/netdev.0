From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] net: phy: Update get_phy_c45_ids for Cortina PHYs
Date: Tue, 23 May 2017 18:55:54 +0200
Message-ID: <20170523165554.GB24029@lunn.ch>
References: <1495554799-23060-1-git-send-email-bogdan.purcareata@nxp.com>
 <1495554799-23060-2-git-send-email-bogdan.purcareata@nxp.com>
 <20170523160353.GB21169@lunn.ch>
 <DB5PR04MB1240098B96F6EEF3730DF054EAF90@DB5PR04MB1240.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Bogdan Purcareata <bogdan.purcareata@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <DB5PR04MB1240098B96F6EEF3730DF054EAF90@DB5PR04MB1240.eurprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The patches mentioned in the commit message add _some_ support for
> the Cortina PHYs - mainly checking for devices at additional
> locations. Once they are found, the phy IDs must be read from custom
> locations.
 
As a general principle, we don't add hacks in generic code to handle
broken devices. We add generic mechanisms to work around the
brokenness.

In this case, by using ethernet-phy-id in the device tree, we are
saying, this PHYs probing is totally borked, but we know it is there,
at this address. Just load the driver.

Please try to make ethernet-phy-id work.

       Andrew
