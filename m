From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: dsa: Bring back device detaching in
 dsa_slave_suspend()
Date: Wed, 25 Jan 2017 19:00:59 +0100
Message-ID: <20170125180059.GD6611@lunn.ch>
References: <20170125171041.21442-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170125171041.21442-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 25, 2017 at 09:10:41AM -0800, Florian Fainelli wrote:
> Commit 448b4482c671 ("net: dsa: Add lockdep class to tx queues to avoid
> lockdep splat") removed the netif_device_detach() call done in
> dsa_slave_suspend() which is necessary, and paired with a corresponding
> netif_device_attach(), bring it back.
> 
> Fixes: 448b4482c671 ("net: dsa: Add lockdep class to tx queues to avoid lockdep splat")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Sorry for accidentally removing it.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
