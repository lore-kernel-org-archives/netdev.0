From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 10/12] net: dsa: support switchdev ageing
 time attr
Date: Tue, 19 Jul 2016 20:50:22 +0200
Message-ID: <20160719185022.GG31103@lunn.ch>
References: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
 <20160719004540.1066-11-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160719004540.1066-11-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2016 at 08:45:38PM -0400, Vivien Didelot wrote:
> Add a new function for DSA drivers to handle the switchdev
> SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME attribute.
> 
> The ageing time is passed as milliseconds.
> 
> Also because we can have multiple logical bridges on top of a physical
> switch and ageing time are switch-wide, call the driver function with
> the fastest ageing time in use on the chip instead of the requested one.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
