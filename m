From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/3] Refactor nested mdiobus read/write functions
Date: Thu, 22 Oct 2015 15:18:31 +0200
Message-ID: <20151022131831.GG1985@lunn.ch>
References: <5628A059.1020402@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5628A059.1020402@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2015 at 10:37:45AM +0200, Neil Armstrong wrote:
> In order to avoid locked signal false positive for nested mdiobus
> read/write calls, nested code was introduced in mv88e6xxx and
> mdio-mux.
> But mv88e6060 also needs such nested mdiobus read/write calls.
> For sake of refactoring, introduce nested variants of mdiobus read/write
> and make them used by mv88e6xxx and mv88e6060.
> In a next patch, mdio-mux should also use these variant calls.
> 
> Neil Armstrong (3):
>   net: phy: Add nested variants of mdiobus read/write
>   net: dsa: Make mv88e6xxx use nested mdiobus read/write
>   net: dsa: Make mv88e6060 use nested mdiobus read/write
> 
>  drivers/net/dsa/mv88e6060.c |  4 ++--
>  drivers/net/dsa/mv88e6xxx.c | 46 ++++++++-----------------------------
>  drivers/net/phy/mdio_bus.c  | 55 +++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/phy.h         |  2 ++
>  4 files changed, 68 insertions(+), 39 deletions(-)

Hi Neil

Thanks for refactoring.

Reviewd-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Andrew Lunn <andrew@lunn.ch>

I tested with a 88E6172 and lockdep enabled.

Thanks
  Andrew
