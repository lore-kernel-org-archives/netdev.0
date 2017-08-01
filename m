From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 08/11] net: dsa: call phy_init_eee in DSA
 layer
Date: Tue, 1 Aug 2017 23:05:43 +0200
Message-ID: <20170801210543.GP23157@lunn.ch>
References: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
 <20170801203241.22294-9-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        John Crispin <john@phrozen.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170801203241.22294-9-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2017 at 04:32:38PM -0400, Vivien Didelot wrote:
> All DSA drivers are calling phy_init_eee if eee_enabled is true.
> 
> Move up this statement in the DSA layer to simplify the DSA drivers.
> qca8k does not require to cache the ethtool_eee structures from now on.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
