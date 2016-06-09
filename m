From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/8] net: dsa: mv88e6xxx: do not increment bus
 refcount
Date: Thu, 9 Jun 2016 04:36:41 +0200
Message-ID: <20160609023641.GJ2227@lunn.ch>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
 <20160609004456.5441-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160609004456.5441-5-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 08, 2016 at 08:44:52PM -0400, Vivien Didelot wrote:
> The MDIO device probe and remove functions are respectively incrementing
> and decrementing the bus refcount themselves. Since these bus level
> actions are out of the device scope, remove them.

I agree with the patch. But have you checked the mdio layer is doing
the right thing? If not, we should fix that first.

    Andrew
