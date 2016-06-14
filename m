From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 01/12] net: dsa: mv88e6xxx: fix style
 issues
Date: Tue, 14 Jun 2016 23:14:33 +0200
Message-ID: <20160614211433.GD12832@lunn.ch>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com>
 <20160614183153.32327-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160614183153.32327-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 14, 2016 at 02:31:42PM -0400, Vivien Didelot wrote:
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
> It also rebases and integrates changes sent by Ben Dooks [1]:
> 
>     The driver has a number of functions that are not exported or
>     declared elsewhere, so make them static to avoid the following
>     warnings from sparse:
> 
>     drivers/net/dsa/mv88e6xxx.c:113:5: warning: symbol 'mv88e6xxx_reg_read' was not declared. Should it be static?
>     drivers/net/dsa/mv88e6xxx.c:167:5: warning: symbol 'mv88e6xxx_reg_write' was not declared. Should it be static?
>     drivers/net/dsa/mv88e6xxx.c:231:5: warning: symbol 'mv88e6xxx_set_addr' was not declared. Should it be static?
>     drivers/net/dsa/mv88e6xxx.c:367:6: warning: symbol 'mv88e6xxx_ppu_state_init' was not declared. Should it be static?
>     drivers/net/dsa/mv88e6xxx.c:3157:5: warning: symbol 'mv88e6xxx_phy_page_read' was not declared. Should it be static?
>     drivers/net/dsa/mv88e6xxx.c:3169:5: warning: symbol 'mv88e6xxx_phy_page_write' was not declared. Should it be static?
>     drivers/net/dsa/mv88e6xxx.c:3583:26: warning: symbol 'mv88e6xxx_switch_driver' was not declared. Should it be static?
>     drivers/net/dsa/mv88e6xxx.c:3621:5: warning: symbol 'mv88e6xxx_probe' was not declared. Should it be static?
> 
> [1] http://patchwork.ozlabs.org/patch/632708/
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
