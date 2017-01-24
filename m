From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v6 4/4] phy: marvell: Add support for the PHY
 embedded in the topaz switch
Date: Tue, 24 Jan 2017 21:28:47 +0100
Message-ID: <20170124202847.GV10895@lunn.ch>
References: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
 <f8526f4a5d99223fc90fe5579b4958eaa0950a3a.1485288602.git-series.gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>,
        Jon Pannell <jpannell@marvell.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f8526f4a5d99223fc90fe5579b4958eaa0950a3a.1485288602.git-series.gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2017 at 09:10:26PM +0100, Gregory CLEMENT wrote:
> The PHY with the ID 0x1410C00

:-(

I don't have a better reference, but
Linux/Documentation/devicetree/bindings/net/phy.txt says:

 22   If the phy's identifier is known then the list may contain an entry
 23   of the form: "ethernet-phy-idAAAA.BBBB" where
 24      AAAA - The value of the 16 bit Phy Identifier 1 register as
 25             4 hex digits. This is the chip vendor OUI bits 3:18
 26      BBBB - The value of the 16 bit Phy Identifier 2 register as
 27             4 hex digits. This is the chip vendor OUI bits 19:24,
 28             followed by 10 bits of a vendor specific ID.

So the lower 10 bits of 0x1410C00 are 0. So we know it is a Marvell
PHY from the OUI, but the vendor specific bits are all 0.

Please take a look at:

https://marc.info/?l=linux-netdev&m=148495522620757&w=1

and

https://marc.info/?l=linux-netdev&m=148495510320714&w=1

Maybe i should submit these two independently, so you can extend it
for the 88E6341 family.

    Andrew
