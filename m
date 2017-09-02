From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: dsa: loop: Do not unregister invalid fixed PHY
Date: Sat, 2 Sep 2017 18:16:36 +0200
Message-ID: <20170902161636.GA5463@lunn.ch>
References: <20170902155645.19071-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170902155645.19071-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 02, 2017 at 08:56:45AM -0700, Florian Fainelli wrote:
> During error injection it was possible to crash in dsa_loop_exit() because of
> an attempt to unregister an invalid PHY. We actually want to the driver probing
> in dsa_loop_init() even though fixed_phy_register() may return an error to
> exercise how DSA deals with such cases, but we should not be crashing during
> driver removal.
> 
> Fixes: 98cd1552ea27 ("net: dsa: Mock-up driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
