From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/8] net: dsa: mv88e6xxx: fix style issues
Date: Thu, 9 Jun 2016 04:22:48 +0200
Message-ID: <20160609022248.GG2227@lunn.ch>
References: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
 <20160609004456.5441-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160609004456.5441-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 08, 2016 at 08:44:49PM -0400, Vivien Didelot wrote:
> This patch fixes 5 style problems reported by checkpatch:
> 
>     WARNING: suspect code indent for conditional statements (8, 24)
>     #492: FILE: drivers/net/dsa/mv88e6xxx.c:492:
>     +	if (phydev->link)
>     +			reg |= PORT_PCS_CTRL_LINK_UP;
> 
>     CHECK: Logical continuations should be on the previous line
>     #1318: FILE: drivers/net/dsa/mv88e6xxx.c:1318:
>     +		     oldstate == PORT_CONTROL_STATE_FORWARDING)
>     +		    && (state == PORT_CONTROL_STATE_DISABLED ||
> 
>     CHECK: multiple assignments should be avoided
>     #1662: FILE: drivers/net/dsa/mv88e6xxx.c:1662:
>     +		vlan->vid_begin = vlan->vid_end = next.vid;
> 
>     WARNING: line over 80 characters
>     #2097: FILE: drivers/net/dsa/mv88e6xxx.c:2097:
>     +				       const struct switchdev_obj_port_vlan *vlan,
> 
>     WARNING: suspect code indent for conditional statements (16, 32)
>     #2734: FILE: drivers/net/dsa/mv88e6xxx.c:2734:
>     +		if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
>     [...]
>     +				reg |= PORT_CONTROL_EGRESS_ADD_TAG;
> 
>     total: 0 errors, 3 warnings, 2 checks, 3805 lines checked
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
