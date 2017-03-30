From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 7/9] net: dsa: mv88e6xxx: remap existing bridge
 members
Date: Thu, 30 Mar 2017 16:07:36 +0200
Message-ID: <20170330140736.GG17879@lunn.ch>
References: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
 <20170329203020.27042-8-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170329203020.27042-8-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 04:30:18PM -0400, Vivien Didelot wrote:
> When a local port of a switch chip becomes a member of a bridge group,
> we need to reprogram the Cross-chip Port Based VLAN Table (PVT) to allow
> existing cross-chip bridge members to egress frames on the new ports.
> 
> There is no functional changes yet, since the PVT is still programmed
> with all ones, allowing any external port to egress frames locally.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
