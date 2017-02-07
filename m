From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/4] net: mv643xx_eth: Do not clobber PHY link
 outside of state machine
Date: Tue, 7 Feb 2017 01:13:25 +0100
Message-ID: <20170207001325.GC30169@lunn.ch>
References: <20170206235523.23216-1-f.fainelli@gmail.com>
 <20170206235523.23216-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, zefir.kurtisi@neratec.com,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Jarod Wilson <jarod@redhat.com>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170206235523.23216-2-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 06, 2017 at 03:55:20PM -0800, Florian Fainelli wrote:
> Calling phy_read_status() means that we may call into
> genphy_read_status() which in turn will use genphy_update_link() which
> can make changes to phydev->link outside of the state machine's state
> transitions. This is an invalid behavior that is now caught as of
> 811a919135b9 ("phy state machine: failsafe leave invalid RUNNING state")
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
