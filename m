From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/9] net: dsa: mv88e6xxx: move PVT description
 in info
Date: Thu, 30 Mar 2017 15:31:36 +0200
Message-ID: <20170330133136.GA17879@lunn.ch>
References: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
 <20170329203020.27042-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170329203020.27042-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 04:30:12PM -0400, Vivien Didelot wrote:
> Not all Marvell switch chips feature a Cross-chip Port VLAN Table (PVT).
> 
> Chips with a PVT use the same implementation, so a new mv88e6xxx_ops
> member won't be necessary yet. Add a "pvt" boolean member to the
> mv88e6xxx_info structure and kill the obsolete MV88E6XXX_FLAGS_PVT flag.
> 
> Add a mv88e6xxx_has_pvt helper to wrap future checks of that condition.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
