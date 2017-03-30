From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/9] net: dsa: mv88e6xxx: use 4-bit port for PVT
 data
Date: Thu, 30 Mar 2017 15:34:23 +0200
Message-ID: <20170330133423.GB17879@lunn.ch>
References: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
 <20170329203020.27042-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170329203020.27042-3-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 04:30:13PM -0400, Vivien Didelot wrote:
> The Cross-chip Port Based VLAN Table (PVT) supports two indexing modes,
> one using 5-bit for device and 4-bit for port, the other using 4-bit for
> device and 5-bit for port, configured via the Global 2 Misc register.
> 
> Only 4 bits for the source port are needed when interconnecting 88E6xxx
> switch devices since they all support less than 16 physical ports. The
> full 5 bits are needed when interconnecting a device with 98DXxxx switch
> devices since they support more than 16 physical ports.
> 
> Add a mv88e6xxx_pvt_setup helper to set the 4-bit port PVT mode, which
> will be extended later to also initialize the PVT content.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
